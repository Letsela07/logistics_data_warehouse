from db_connection import get_engine
from extract import extract_all_data
from load_bronze import truncate_bronze_tables, load_bronze_tables
from execute_procedures import load_silver_layer


def main():
    engine = get_engine()

    print("Extracting CSV data...")
    dataframes = extract_all_data()

    print("Loading Bronze tables...")
    truncate_bronze_tables(engine)
    load_bronze_tables(engine, dataframes)

    load_silver_layer(engine)

    print("ETL pipeline completed successfully")


if __name__ == "__main__":
    main()