from pathlib import Path

import boto3

from config import AWS_REGION, S3_BUCKET_NAME


BASE_DIR = Path(__file__).resolve().parent.parent
DATASETS_DIR = BASE_DIR / "datasets"

s3 = boto3.client("s3", region_name=AWS_REGION)


def upload_file(filename: str, s3_key: str):
    file_path = DATASETS_DIR / filename

    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    s3.upload_file(
        str(file_path),
        S3_BUCKET_NAME,
        s3_key,
    )

    print(f"Uploaded {filename} → s3://{S3_BUCKET_NAME}/{s3_key}")


def upload_all_datasets():
    datasets = {
        "customer.csv": "raw_data/customer/customer.csv",
        "shipment.csv": "raw_data/shipment/shipment.csv",
        "logistics_performance.csv": (
            "raw_data/logistics_performance/logistics_performance.csv"
        ),
    }

    for filename, s3_key in datasets.items():
        upload_file(filename, s3_key)


if __name__ == "__main__":
    upload_all_datasets()