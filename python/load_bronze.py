from sqlalchemy import text


def truncate_bronze_tables(engine):
    tables = [
        "bronze.customer",
        "bronze.shipment",
        "bronze.logistics_performance",
    ]

    with engine.begin() as conn:
        for table in tables:
            conn.execute(text(f"TRUNCATE TABLE {table}"))
            print(f"Truncated {table}")


def load_bronze_tables(engine, dataframes):
    table_mapping = {
        "customer": ("customer", "bronze"),
        "shipment": ("shipment", "bronze"),
        "logistics_performance": ("logistics_performance", "bronze"),
    }

    for name, df in dataframes.items():
        table_name, schema = table_mapping[name]

        df.to_sql(
            name=table_name,
            con=engine,
            schema=schema,
            if_exists="append",
            index=False,
            chunksize=100,
        )

        print(f"Loaded {len(df)} rows into {schema}.{table_name}")