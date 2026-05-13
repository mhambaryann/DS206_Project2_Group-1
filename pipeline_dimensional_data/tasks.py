import re
from pathlib import Path

from pipeline_dimensional_data import config


GO_STATEMENT_PATTERN = re.compile(
    r"^\s*GO(?:\s+(?P<count>\d+))?\s*(?:--.*)?$",
    re.IGNORECASE,
)

DIMENSION_LOAD_ORDER = (
    "categories",
    "customers",
    "employees",
    "region",
    "shippers",
    "suppliers",
    "products",
    "territories",
)


def _default_connection_factory():
    from utils import get_db_connection

    return get_db_connection()


def read_sql_script(script_path):
    path = Path(script_path)
    if not path.exists():
        raise FileNotFoundError(f"SQL script not found: {path}")
    return path.read_text(encoding="utf-8")


def substitute_sql_params(sql_text, params=None):
    rendered_sql = sql_text
    for key, value in (params or {}).items():
        rendered_sql = rendered_sql.replace("{" + key + "}", str(value))

    missing_params = sorted(set(re.findall(r"{([A-Za-z_][A-Za-z0-9_]*)}", rendered_sql)))
    if missing_params:
        missing = ", ".join(missing_params)
        raise ValueError(f"Missing SQL parameter value(s): {missing}")

    return rendered_sql


def split_sql_batches(sql_text):
    batches = []
    current_lines = []

    for line in sql_text.splitlines():
        go_match = GO_STATEMENT_PATTERN.match(line)
        if go_match:
            batch = "\n".join(current_lines).strip()
            if batch:
                repeat_count = int(go_match.group("count") or 1)
                batches.extend([batch] * repeat_count)
            current_lines = []
            continue

        current_lines.append(line)

    final_batch = "\n".join(current_lines).strip()
    if final_batch:
        batches.append(final_batch)

    return batches


def build_dimension_task_specs():
    task_specs = []
    for dimension_name in DIMENSION_LOAD_ORDER:
        task_specs.append(
            {
                "name": f"update_dim_{dimension_name}",
                "script_path": config.DIMENSION_QUERY_PATHS[dimension_name],
                "params": {
                    "db_name": config.DB_NAME,
                    "schema_name": config.SCHEMA_NAME,
                    "table_name": config.DIMENSION_TABLES[dimension_name],
                },
            }
        )
    return task_specs


def build_fact_task_specs(start_date, end_date):
    fact_params = {
        **config.FACT_QUERY_PARAMS,
        "start_date": start_date,
        "end_date": end_date,
    }
    fact_error_params = {
        **config.FACT_ERROR_QUERY_PARAMS,
        "start_date": start_date,
        "end_date": end_date,
    }

    return [
        {
            "name": "update_fact",
            "script_path": config.FACT_QUERY_PATH,
            "params": fact_params,
        },
        {
            "name": "update_fact_error",
            "script_path": config.FACT_ERROR_QUERY_PATH,
            "params": fact_error_params,
        },
    ]


def execute_task_specs(task_specs, connection_factory=None, logger=None):
    connection_factory = connection_factory or _default_connection_factory
    connection = None
    cursor = None
    task_results = []
    total_batches = 0

    try:
        connection = connection_factory()
        cursor = connection.cursor()

        for task_spec in task_specs:
            task_name = task_spec["name"]
            script_path = task_spec["script_path"]
            params = task_spec.get("params", {})

            if logger:
                logger.info("Running task %s from %s", task_name, script_path)

            sql_text = read_sql_script(script_path)
            rendered_sql = substitute_sql_params(sql_text, params)
            batches = split_sql_batches(rendered_sql)

            for batch_index, batch in enumerate(batches, start=1):
                cursor.execute(batch)
                total_batches += 1

            task_results.append(
                {
                    "task": task_name,
                    "script_path": str(script_path),
                    "batches_executed": len(batches),
                }
            )

        connection.commit()

        return {
            "success": True,
            "tasks": task_results,
            "tasks_executed": len(task_results),
            "batches_executed": total_batches,
        }

    except Exception as exc:
        if connection is not None:
            try:
                connection.rollback()
            except Exception:
                pass

        if logger:
            logger.exception("Pipeline task execution failed")

        return {
            "success": False,
            "error": str(exc),
            "tasks": task_results,
            "tasks_executed": len(task_results),
            "batches_executed": total_batches,
        }

    finally:
        if cursor is not None:
            try:
                cursor.close()
            except Exception:
                pass
        if connection is not None:
            try:
                connection.close()
            except Exception:
                pass


def run_dimension_updates(connection_factory=None, logger=None):
    return execute_task_specs(
        build_dimension_task_specs(),
        connection_factory=connection_factory,
        logger=logger,
    )


def run_fact_updates(start_date, end_date, connection_factory=None, logger=None):
    return execute_task_specs(
        build_fact_task_specs(start_date, end_date),
        connection_factory=connection_factory,
        logger=logger,
    )


def run_dimensional_pipeline_tasks(start_date, end_date, connection_factory=None, logger=None):
    task_specs = build_dimension_task_specs()
    task_specs.extend(build_fact_task_specs(start_date, end_date))

    return execute_task_specs(
        task_specs,
        connection_factory=connection_factory,
        logger=logger,
    )
