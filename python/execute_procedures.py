from sqlalchemy import text

from logger import get_logger

logger = get_logger()


def load_silver_layer(engine):
    try:
        logger.info("Executing dbo.usp_load_silver")

        with engine.begin() as conn:
            conn.execute(text("EXEC dbo.usp_load_silver"))

        logger.info("dbo.usp_load_silver completed successfully")

    except Exception:
        logger.exception("dbo.usp_load_silver failed")
        raise