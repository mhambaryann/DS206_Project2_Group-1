import configparser
import os
import uuid

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

def get_db_connection():
    """Creates a connection to the SQL Server database."""
    import pyodbc

    cfg = get_config()
    # Using Trusted Connection for local SQL Server
    conn_str = (
        f"DRIVER={cfg['driver']};"
        f"SERVER={cfg['server']};"
        f"DATABASE={cfg['database']};"
        f"Trusted_Connection=yes;"
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
