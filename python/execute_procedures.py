from sqlalchemy import text


def load_silver_layer(engine):
    print("Loading Silver layer...")

    with engine.begin() as conn:
        conn.execute(text("EXEC dbo.usp_load_silver"))

    print("Silver layer loaded successfully")