from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent
DATASETS_DIR = BASE_DIR / "datasets"


def read_csv_file(filename: str) -> pd.DataFrame:
    file_path = DATASETS_DIR / filename

    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    df = pd.read_csv(file_path)

    # Clean column names
    df.columns = df.columns.str.strip()

    # Clean text values
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.strip()

    return df


def extract_all_data():
    return {
        "customer": read_csv_file("customer.csv"),
        "shipment": read_csv_file("shipment.csv"),
        "logistics_performance": read_csv_file("logistics_performance.csv"),
    }