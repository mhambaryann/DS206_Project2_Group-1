import uuid
from unittest.mock import Mock

from pipeline_dimensional_data import flow as flow_module
from pipeline_dimensional_data.flow import DimensionalDataFlow


def test_dimensional_data_flow_init_creates_execution_id():
    flow = DimensionalDataFlow()

    parsed_uuid = uuid.UUID(flow.execution_id)
    assert str(parsed_uuid) == flow.execution_id


def test_dimensional_data_flow_exec_calls_task_runner_with_supplied_dates(monkeypatch):
    runner = Mock(return_value={"success": True, "tasks_executed": 1, "batches_executed": 1})
    monkeypatch.setattr(flow_module.tasks, "run_dimensional_pipeline_tasks", runner)
    connection_factory = Mock()
    logger = Mock()
    flow = DimensionalDataFlow(connection_factory=connection_factory, logger=logger)

    result = flow.exec("2026-01-01", "2026-01-31")

    runner.assert_called_once_with(
        start_date="2026-01-01",
        end_date="2026-01-31",
        connection_factory=connection_factory,
        logger=logger,
    )
    assert result["success"] is True


def test_dimensional_data_flow_exec_returns_same_execution_id(monkeypatch):
    runner = Mock(return_value={"success": True, "tasks_executed": 0, "batches_executed": 0})
    monkeypatch.setattr(flow_module.tasks, "run_dimensional_pipeline_tasks", runner)
    flow = DimensionalDataFlow()

    result = flow.exec("2026-02-01", "2026-02-28")

    assert result["execution_id"] == flow.execution_id