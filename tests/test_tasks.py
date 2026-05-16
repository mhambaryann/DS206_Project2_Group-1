from pathlib import Path
from unittest.mock import Mock

import pytest

from pipeline_dimensional_data import config, tasks


class FakeConnection:
    def __init__(self, cursor):
        self._cursor = cursor
        self.commit = Mock()
        self.rollback = Mock()
        self.close = Mock()

    def cursor(self):
        return self._cursor


def make_connection_factory(cursor):
    connection = FakeConnection(cursor)
    return Mock(return_value=connection), connection


def test_substitute_sql_params_replaces_all_placeholders():
    sql = "USE [{db_name}]; SELECT '{start_date}' AS start_date, '{end_date}' AS end_date;"

    rendered = tasks.substitute_sql_params(
        sql,
        {
            "db_name": "ORDER_DDS",
            "start_date": "2026-01-01",
            "end_date": "2026-01-31",
        },
    )

    assert rendered == (
        "USE [ORDER_DDS]; SELECT '2026-01-01' AS start_date, "
        "'2026-01-31' AS end_date;"
    )


def test_substitute_sql_params_raises_value_error_when_placeholder_is_missing():
    sql = "SELECT * FROM [{db_name}].[{schema_name}].[{table_name}];"

    with pytest.raises(ValueError, match="schema_name, table_name"):
        tasks.substitute_sql_params(sql, {"db_name": "ORDER_DDS"})


def test_split_sql_batches_splits_on_go_statement():
    sql = "SELECT 1 AS first;\nGO\nSELECT 2 AS second;\nGO\n"

    assert tasks.split_sql_batches(sql) == ["SELECT 1 AS first;", "SELECT 2 AS second;"]


def test_split_sql_batches_repeats_batch_when_go_has_count():
    sql = "INSERT INTO AuditLog VALUES (1);\nGO 2\nSELECT COUNT(*) FROM AuditLog;"

    assert tasks.split_sql_batches(sql) == [
        "INSERT INTO AuditLog VALUES (1);",
        "INSERT INTO AuditLog VALUES (1);",
        "SELECT COUNT(*) FROM AuditLog;",
    ]


def test_execute_task_specs_commits_when_all_batches_succeed(tmp_path):
    script = tmp_path / "task.sql"
    script.write_text("SELECT 1;\nGO\nSELECT 2;", encoding="utf-8")
    cursor = Mock()
    connection_factory, connection = make_connection_factory(cursor)

    result = tasks.execute_task_specs(
        [
            {
                "name": "sample_task",
                "script_path": script,
                "params": {},
            }
        ],
        connection_factory=connection_factory,
    )

    assert result["success"] is True
    assert result["tasks_executed"] == 1
    assert result["batches_executed"] == 2
    assert cursor.execute.call_count == 2
    connection.commit.assert_called_once()
    connection.rollback.assert_not_called()


def test_execute_task_specs_rolls_back_when_a_batch_fails(tmp_path):
    script = tmp_path / "task.sql"
    script.write_text("SELECT 1;\nGO\nSELECT broken;", encoding="utf-8")
    cursor = Mock()
    cursor.execute.side_effect = [None, RuntimeError("SQL failure")]
    connection_factory, connection = make_connection_factory(cursor)

    result = tasks.execute_task_specs(
        [
            {
                "name": "failing_task",
                "script_path": script,
                "params": {},
            }
        ],
        connection_factory=connection_factory,
    )

    assert result["success"] is False
    assert "SQL failure" in result["error"]
    assert result["batches_executed"] == 1
    connection.commit.assert_not_called()
    connection.rollback.assert_called_once()


def test_execute_task_specs_closes_cursor_and_connection_on_success(tmp_path):
    script = tmp_path / "task.sql"
    script.write_text("SELECT 1;", encoding="utf-8")
    cursor = Mock()
    connection_factory, connection = make_connection_factory(cursor)

    tasks.execute_task_specs(
        [{"name": "sample_task", "script_path": script, "params": {}}],
        connection_factory=connection_factory,
    )

    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_execute_task_specs_closes_cursor_and_connection_on_failure(tmp_path):
    script = tmp_path / "task.sql"
    script.write_text("SELECT broken;", encoding="utf-8")
    cursor = Mock()
    cursor.execute.side_effect = RuntimeError("SQL failure")
    connection_factory, connection = make_connection_factory(cursor)

    tasks.execute_task_specs(
        [{"name": "sample_task", "script_path": script, "params": {}}],
        connection_factory=connection_factory,
    )

    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_build_fact_task_specs_includes_start_and_end_dates():
    specs = tasks.build_fact_task_specs("2026-01-01", "2026-01-31")

    assert [spec["name"] for spec in specs] == ["update_fact", "update_fact_error"]
    for spec in specs:
        assert spec["params"]["start_date"] == "2026-01-01"
        assert spec["params"]["end_date"] == "2026-01-31"

    assert specs[0]["params"]["fact_table"] == config.FACT_TABLE
    assert specs[1]["params"]["error_table"] == config.ERROR_TABLE


def test_build_dimension_task_specs_uses_intended_dimension_order():
    specs = tasks.build_dimension_task_specs()

    assert [spec["name"] for spec in specs] == [
        "update_dim_categories",
        "update_dim_customers",
        "update_dim_employees",
        "update_dim_region",
        "update_dim_shippers",
        "update_dim_suppliers",
        "update_dim_products",
        "update_dim_territories",
    ]
    assert [spec["params"]["table_name"] for spec in specs] == [
        config.DIMENSION_TABLES[name] for name in tasks.DIMENSION_LOAD_ORDER
    ]