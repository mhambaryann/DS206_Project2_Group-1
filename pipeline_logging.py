import os
import logging

from utils import generate_execution_id

def setup_logging(execution_id=None):
    """
    Requirement #13: Sets up a logger for the dimensional data flow.
    Includes execution_id (UUID) and writes to logs/logs_dimensional_data_pipeline.txt.
    """
    log_dir = 'logs'
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    log_file = os.path.join(log_dir, 'logs_dimensional_data_pipeline.txt')
    
    if execution_id is None:
        execution_id = generate_execution_id()
    
    log_format = f'%(asctime)s - %(levelname)s - [ExecID: {execution_id}] - %(message)s'
    
    
    logging.basicConfig(
        level=logging.INFO,
        format=log_format,
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ],
        force=True
    )
    
    logger = logging.getLogger('DDS_Pipeline')
    logger.info("--- Pipeline Execution Started ---")
    return logger, execution_id
