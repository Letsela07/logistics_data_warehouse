import sys
from pathlib import Path

import boto3
from botocore.exceptions import BotoCoreError, ClientError


PROJECT_ROOT = Path(__file__).resolve().parent.parent
PYTHON_DIR = PROJECT_ROOT / "python"

sys.path.insert(0, str(PYTHON_DIR))

from config import AWS_REGION, S3_BUCKET_NAME


def test_s3_connection():
    try:
        s3 = boto3.client("s3", region_name=AWS_REGION)

        response = s3.head_bucket(Bucket=S3_BUCKET_NAME)

        if response["ResponseMetadata"]["HTTPStatusCode"] == 200:
            print(f"S3 connection successful: s3://{S3_BUCKET_NAME}")

    except (BotoCoreError, ClientError) as exc:
        print(f"S3 connection failed: {exc}")
        raise


if __name__ == "__main__":
    test_s3_connection()