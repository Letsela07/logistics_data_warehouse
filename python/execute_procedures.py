from pathlib import Path
from sqlalchemy import text

BASE_DIR = Path(__file__).resolve().parent.parent
SILVER_SCRIPT_PATH = BASE_DIR / "sql" / "silver" / "load_silver_data.sql"


def execute_sql_script(engine, script_path):
    with open(script_path, "r", encoding="utf-8") as file:
        sql_script = file.read()

    statements = [stmt.strip() for stmt in sql_script.split(";") if stmt.strip()]

    with engine.begin() as conn:
        for statement in statements:
            conn.execute(text(statement))


def load_silver_layer(engine):
    print("Loading Silver layer...")
    execute_sql_script(engine, SILVER_SCRIPT_PATH)
    print("Silver layer loaded successfully")