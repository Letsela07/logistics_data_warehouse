import sys
from pathlib import Path

import pandas as pd
import pytest

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PYTHON_DIR = PROJECT_ROOT / "python"

sys.path.insert(0, str(PYTHON_DIR))

from validation import (
    validate_no_nulls,
    validate_row_count,
    validate_unique,
)


def test_customer_row_count_passes():
    df = pd.DataFrame({"customer_id": range(750)})

    validate_row_count(df, "customer")


def test_customer_row_count_fails():
    df = pd.DataFrame({"customer_id": range(749)})

    with pytest.raises(ValueError):
        validate_row_count(df, "customer")


def test_required_columns_have_no_nulls():
    df = pd.DataFrame(
        {
            "customer_id": [1, 2, 3],
            "customer_name": ["A", "B", "C"],
        }
    )

    validate_no_nulls(
        df,
        ["customer_id", "customer_name"],
    )


def test_required_columns_with_nulls_fail():
    df = pd.DataFrame(
        {
            "customer_id": [1, 2, None],
            "customer_name": ["A", "B", "C"],
        }
    )

    with pytest.raises(ValueError):
        validate_no_nulls(
            df,
            ["customer_id", "customer_name"],
        )


def test_unique_columns_pass():
    df = pd.DataFrame(
        {
            "customer_id": [1, 2, 3],
        }
    )

    validate_unique(df, ["customer_id"])


def test_duplicate_columns_fail():
    df = pd.DataFrame(
        {
            "customer_id": [1, 2, 2],
        }
    )

    with pytest.raises(ValueError):
        validate_unique(df, ["customer_id"])