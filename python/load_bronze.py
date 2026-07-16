from sqlalchemy import text

from logger import get_logger

logger = get_logger()


def truncate_bronze_tables(engine):
    tables = [
        "bronze.customer",
        "bronze.shipment",
        "bronze.logistics_performance",
    ]

    with engine.begin() as conn:
        for table in tables:
            conn.execute(text(f"TRUNCATE TABLE {table}"))
            logger.info("Truncated %s", table)


def load_bronze_tables(engine, dataframes):
    table_mapping = {
        "customer": ("customer", "bronze"),
        "shipment": ("shipment", "bronze"),
        "logistics_performance": ("logistics_performance", "bronze"),
    }

    for name, df in dataframes.items():
        table_name, schema = table_mapping[name]

        try:
            df.to_sql(
                name=table_name,
                con=engine,
                schema=schema,
                if_exists="append",
                index=False,
                chunksize=100,
            )

            logger.info(
                "Loaded %s rows into %s.%s",
                len(df),
                schema,
                table_name,
            )

        except Exception:
            logger.exception(
                "Failed loading %s.%s",
                schema,
                table_name,
            )
            raise