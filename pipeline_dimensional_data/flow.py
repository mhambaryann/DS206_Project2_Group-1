from utils import generate_execution_id

from pipeline_dimensional_data import tasks


class DimensionalDataFlow:
    def __init__(self, connection_factory=None, logger=None):
        self.execution_id = generate_execution_id()
        self.connection_factory = connection_factory
        self.logger = logger

    def exec(self, start_date, end_date):
        if self.logger:
            self.logger.info(
                "Starting dimensional data flow execution_id=%s start_date=%s end_date=%s",
                self.execution_id,
                start_date,
                end_date,
            )

        result = tasks.run_dimensional_pipeline_tasks(
            start_date=start_date,
            end_date=end_date,
            connection_factory=self.connection_factory,
            logger=self.logger,
        )
        result["execution_id"] = self.execution_id

        if self.logger:
            if result.get("success"):
                self.logger.info(
                    "Finished dimensional data flow execution_id=%s tasks_executed=%s batches_executed=%s",
                    self.execution_id,
                    result.get("tasks_executed"),
                    result.get("batches_executed"),
                )
            else:
                self.logger.error(
                    "Dimensional data flow failed execution_id=%s error=%s",
                    self.execution_id,
                    result.get("error"),
                )

        return result
