from db_connection import get_engine
from execute_procedures import load_silver_layer
from extract import extract_all_data
from load_bronze import load_bronze_tables, truncate_bronze_tables
from logger import get_logger
from s3 import upload_all_datasets
from validation import (
    validate_no_nulls,
    validate_row_count,
    validate_unique,
)

logger = get_logger()


def main():
    logger.info("ETL pipeline started")

    try:
        engine = get_engine()
        logger.info("Database engine created successfully")

        logger.info("Extracting CSV data")
        dataframes = extract_all_data()

        logger.info("Running data quality validation")

        validate_row_count(dataframes["customer"], "customer")
        validate_row_count(dataframes["shipment"], "shipment")
        validate_row_count(
            dataframes["logistics_performance"],
            "logistics_performance",
        )

        validate_no_nulls(
            dataframes["customer"],
            ["customer_id"],
        )

        validate_no_nulls(
            dataframes["shipment"],
            ["shipment_id"],
        )

        validate_no_nulls(
            dataframes["logistics_performance"],
            ["date","region","carrier"],
        )

        validate_unique(
            dataframes["customer"],
            ["customer_id"],
        )

        validate_unique(
            dataframes["shipment"],
            ["shipment_id"],
        )

        logger.info("Data quality validation passed")

        for name, df in dataframes.items():
            logger.info("Extracted %s rows from %s", len(df), name)

        logger.info("Uploading raw data to S3")
        upload_all_datasets()
        logger.info("Raw data uploaded to S3 successfully")

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