from urllib.parse import quote_plus
from sqlalchemy import create_engine

from config import DB_SERVER, DB_DATABASE, DB_DRIVER, DB_USERNAME, DB_PASSWORD


def get_engine():
    if DB_USERNAME and DB_PASSWORD:
        connection_string = (
            f"DRIVER={{{DB_DRIVER}}};"
            f"SERVER={DB_SERVER};"
            f"DATABASE={DB_DATABASE};"
            f"UID={DB_USERNAME};"
            f"PWD={DB_PASSWORD};"
            f"TrustServerCertificate=yes;"
        )
    else:
        connection_string = (
            f"DRIVER={{{DB_DRIVER}}};"
            f"SERVER={DB_SERVER};"
            f"DATABASE={DB_DATABASE};"
            f"Trusted_Connection=yes;"
        )

    return create_engine(
        f"mssql+pyodbc:///?odbc_connect={quote_plus(connection_string)}"
    )