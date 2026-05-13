import configparser
import os
import uuid

REQUIRED_SQL_CONFIG_KEYS = ("driver", "server", "database")


def generate_execution_id():
    """Generates a unique UUID for execution tracking."""
    return str(uuid.uuid4())

def get_config(config_file='sql_server_config.cfg'):
    """Parses the configuration file."""
    config = configparser.ConfigParser()
    loaded_files = config.read(config_file)
    if not loaded_files:
        raise FileNotFoundError(f"Config file not found: {config_file}")
    if 'sql_server' not in config:
        raise KeyError("Section 'sql_server' not found in config file.")
    return config['sql_server']


def normalize_odbc_driver_name(driver_name):
    """Normalizes ODBC driver names from config values like {ODBC Driver 18 for SQL Server}."""
    return str(driver_name).strip().strip("{}")


def get_available_odbc_drivers():
    """Returns registered ODBC drivers without requiring callers to import pyodbc directly."""
    import pyodbc

    return pyodbc.drivers()


def validate_sql_config(cfg):
    """Validates required SQL Server config keys."""
    missing_keys = [key for key in REQUIRED_SQL_CONFIG_KEYS if not cfg.get(key)]
    if missing_keys:
        raise KeyError(f"Missing required SQL config key(s): {', '.join(missing_keys)}")


def validate_odbc_driver(driver_name):
    """Checks whether the configured ODBC driver is installed and registered."""
    configured_driver = normalize_odbc_driver_name(driver_name)
    available_drivers = get_available_odbc_drivers()
    normalized_available = {normalize_odbc_driver_name(driver) for driver in available_drivers}

    if configured_driver not in normalized_available:
        available = ", ".join(available_drivers) if available_drivers else "none"
        raise ConnectionError(
            f"Configured ODBC driver '{configured_driver}' is not installed or registered. "
            f"Available ODBC drivers: {available}"
        )


def get_db_connection():
    """Creates a connection to the SQL Server database."""
    import pyodbc

    cfg = get_config()
    validate_sql_config(cfg)
    validate_odbc_driver(cfg['driver'])

    conn_str = (
        f"DRIVER={cfg['driver']};"
        f"SERVER={cfg['server']};"
        f"DATABASE={cfg['database']};"
        f"Trusted_Connection={cfg.get('trusted_connection', 'yes')};"
    )
    try:
        return pyodbc.connect(conn_str)
    except Exception as exc:
        raise ConnectionError(f"Failed to connect to SQL Server: {exc}") from exc

def read_sql_script(script_path):
    """Reads a .sql file and returns the string."""
    if not os.path.exists(script_path):
        raise FileNotFoundError(f"SQL script not found at {script_path}")
    with open(script_path, 'r') as file:
        return file.read()
