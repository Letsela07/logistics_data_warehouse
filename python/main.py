from db_connection import get_engine
from execute_procedures import load_silver_layer
from extract import extract_all_data
from load_bronze import load_bronze_tables, truncate_bronze_tables
from logger import get_logger

logger = get_logger()


def main():
    logger.info("ETL pipeline started")

    try:
        engine = get_engine()
        logger.info("Database engine created successfully")

        logger.info("Extracting CSV data")
        dataframes = extract_all_data()

        for name, df in dataframes.items():
            logger.info("Extracted %s rows from %s", len(df), name)

        logger.info("Loading Bronze tables")
        truncate_bronze_tables(engine)
        load_bronze_tables(engine, dataframes)
        logger.info("Bronze layer loaded successfully")

        logger.info("Loading Silver layer")
        load_silver_layer(engine)
        logger.info("Silver layer loaded successfully")

        logger.info("ETL pipeline completed successfully")

    except Exception:
        logger.exception("ETL pipeline failed")
        raise


if __name__ == "__main__":
    main()