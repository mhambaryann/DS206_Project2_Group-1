import sys
import types
import uuid
from pathlib import Path
from unittest.mock import Mock

import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import utils


def test_generate_execution_id_returns_valid_uuid():
    execution_id = utils.generate_execution_id()

    parsed_uuid = uuid.UUID(execution_id)
    assert str(parsed_uuid) == execution_id


def test_generate_execution_id_returns_unique_values():
    first_id = utils.generate_execution_id()
    second_id = utils.generate_execution_id()

    assert first_id != second_id


def test_get_config_success_path(tmp_path):
    config_file = tmp_path / "sql_server_config.cfg"
    config_file.write_text(
        "\n".join(
            [
                "[sql_server]",
                "server = localhost",
                "database = ORDER_DDS",
                "driver = {ODBC Driver 18 for SQL Server}",
            ]
        ),
        encoding="utf-8",
    )

    cfg = utils.get_config(str(config_file))

    assert cfg["server"] == "localhost"
    assert cfg["database"] == "ORDER_DDS"
    assert cfg["driver"] == "{ODBC Driver 18 for SQL Server}"


def test_get_config_missing_file_raises_file_not_found(tmp_path):
    missing_config = tmp_path / "missing.cfg"

    with pytest.raises(FileNotFoundError, match="Config file not found"):
        utils.get_config(str(missing_config))


def test_get_config_missing_sql_server_section_raises_key_error(tmp_path):
    config_file = tmp_path / "bad_config.cfg"
    config_file.write_text("[other]\nserver = localhost\n", encoding="utf-8")

    with pytest.raises(KeyError, match="sql_server"):
        utils.get_config(str(config_file))


def test_get_config_empty_file_raises_key_error(tmp_path):
    config_file = tmp_path / "empty_config.cfg"
    config_file.write_text("", encoding="utf-8")

    with pytest.raises(KeyError, match="sql_server"):
        utils.get_config(str(config_file))


def test_normalize_odbc_driver_name_removes_outer_braces():
    assert utils.normalize_odbc_driver_name("{ODBC Driver 18 for SQL Server}") == (
        "ODBC Driver 18 for SQL Server"
    )


def test_validate_sql_config_missing_required_key_raises_key_error():
    with pytest.raises(KeyError, match="database"):
        utils.validate_sql_config(
            {
                "driver": "{ODBC Driver 18 for SQL Server}",
                "server": "localhost",
            }
        )


def test_validate_odbc_driver_missing_driver_raises_connection_error(monkeypatch):
    monkeypatch.setattr(utils, "get_available_odbc_drivers", lambda: [])

    with pytest.raises(ConnectionError, match="not installed or registered"):
        utils.validate_odbc_driver("{ODBC Driver 18 for SQL Server}")


def test_read_sql_script_success_path(tmp_path):
    script_file = tmp_path / "query.sql"
    script_file.write_text("SELECT 1;", encoding="utf-8")

    assert utils.read_sql_script(str(script_file)) == "SELECT 1;"


def test_read_sql_script_missing_file_raises_file_not_found(tmp_path):
    missing_script = tmp_path / "missing.sql"

    with pytest.raises(FileNotFoundError, match="SQL script not found"):
        utils.read_sql_script(str(missing_script))


def test_get_db_connection_calls_pyodbc_with_expected_connection_string(monkeypatch):
    expected_connection = object()
    connect_mock = Mock(return_value=expected_connection)
    fake_pyodbc = types.SimpleNamespace(
        connect=connect_mock,
        drivers=lambda: ["ODBC Driver 18 for SQL Server"],
    )

    monkeypatch.setitem(sys.modules, "pyodbc", fake_pyodbc)
    monkeypatch.setattr(
        utils,
        "get_config",
        lambda: {
            "driver": "{ODBC Driver 18 for SQL Server}",
            "server": "localhost",
            "database": "ORDER_DDS",
        },
    )

    connection = utils.get_db_connection()

    assert connection is expected_connection
    connect_mock.assert_called_once_with(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=ORDER_DDS;"
        "Trusted_Connection=yes;"
    )


def test_get_db_connection_wraps_pyodbc_failure(monkeypatch):
    connect_mock = Mock(side_effect=RuntimeError("driver unavailable"))
    fake_pyodbc = types.SimpleNamespace(
        connect=connect_mock,
        drivers=lambda: ["ODBC Driver 18 for SQL Server"],
    )

    monkeypatch.setitem(sys.modules, "pyodbc", fake_pyodbc)
    monkeypatch.setattr(
        utils,
        "get_config",
        lambda: {
            "driver": "{ODBC Driver 18 for SQL Server}",
            "server": "localhost",
            "database": "ORDER_DDS",
        },
    )

    with pytest.raises(ConnectionError, match="Failed to connect to SQL Server"):
        utils.get_db_connection()


def test_get_db_connection_reports_missing_driver_before_connect(monkeypatch):
    connect_mock = Mock()
    fake_pyodbc = types.SimpleNamespace(connect=connect_mock, drivers=lambda: [])

    monkeypatch.setitem(sys.modules, "pyodbc", fake_pyodbc)
    monkeypatch.setattr(
        utils,
        "get_config",
        lambda: {
            "driver": "{ODBC Driver 18 for SQL Server}",
            "server": "localhost",
            "database": "ORDER_DDS",
        },
    )

    with pytest.raises(ConnectionError, match="not installed or registered"):
        utils.get_db_connection()

    connect_mock.assert_not_called()
