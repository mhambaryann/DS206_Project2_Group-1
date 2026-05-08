import os
import sys

# --- WORKAROUND FOR NAME COLLISION ---
# Because this file is named 'logging.py', it shadows the built-in module.
# We must temporarily remove 'logging' from sys.modules and sys.path to get the real one.

_current_dir = os.path.dirname(os.path.abspath(__file__))
_original_path = sys.path[:]
sys.path = [p for p in sys.path if os.path.abspath(p or '.') != _current_dir]

# Temporarily pop 'logging' from modules so it can be re-imported from system library
_local_logging = sys.modules.pop('logging', None)

import logging as _system_logging

# Restore original path and module registry
sys.path = _original_path
if _local_logging:
    sys.modules['logging'] = _local_logging
# --------------------------------------

from utils import generate_execution_id

def setup_logging():
    """
    Requirement #13: Sets up a logger for the dimensional data flow.
    Includes execution_id (UUID) and writes to logs/logs_dimensional_data_pipeline.txt.
    """
    log_dir = 'logs'
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    log_file = os.path.join(log_dir, 'logs_dimensional_data_pipeline.txt')
    
   
    execution_id = generate_execution_id()
    
    log_format = f'%(asctime)s - %(levelname)s - [ExecID: {execution_id}] - %(message)s'
    
    
    _system_logging.basicConfig(
        level=_system_logging.INFO,
        format=log_format,
        handlers=[
            _system_logging.FileHandler(log_file),
            _system_logging.StreamHandler()
        ],
        force=True
    )
    
    logger = _system_logging.getLogger('DDS_Pipeline')
    logger.info("--- Pipeline Execution Started ---")
    return logger, execution_id