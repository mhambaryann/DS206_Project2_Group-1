import argparse
from logging import setup_logging

def main():
    # Initialize logger and get the execution UUID
    logger, exec_id = setup_logging()
    
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='DS 206 Dimensional Data Pipeline')
    parser.add_argument('--start_date', required=True, help='Start date YYYY-MM-DD')
    parser.add_argument('--end_date', required=True, help='End date YYYY-MM-DD')
    
    args = parser.parse_args()
    
    logger.info(f"Start Date: {args.start_date}")
    logger.info(f"End Date: {args.end_date}")
    logger.info(f"Execution Context ID: {exec_id}")
    
    # The actual processing logic will go here
    
    logger.info("--- Pipeline Execution Finished ---")

if __name__ == "__main__":
    main()
