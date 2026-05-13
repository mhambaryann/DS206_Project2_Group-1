import argparse
from pipeline_logging import setup_logging
from pipeline_dimensional_data.flow import DimensionalDataFlow

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='DS 206 Dimensional Data Pipeline')
    parser.add_argument('--start_date', required=True, help='Start date YYYY-MM-DD')
    parser.add_argument('--end_date', required=True, help='End date YYYY-MM-DD')
    
    args = parser.parse_args()

    flow = DimensionalDataFlow()
    logger, exec_id = setup_logging(flow.execution_id)
    flow.logger = logger
    
    logger.info(f"Start Date: {args.start_date}")
    logger.info(f"End Date: {args.end_date}")
    logger.info(f"Execution Context ID: {exec_id}")
    
    result = flow.exec(start_date=args.start_date, end_date=args.end_date)
    if not result.get("success"):
        logger.error(f"Pipeline execution failed: {result.get('error')}")
        return 1
    
    logger.info("--- Pipeline Execution Finished ---")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
