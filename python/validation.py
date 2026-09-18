import pandas as pd


EXPECTED_ROW_COUNTS = {
    "customer": 750,
    "shipment": 728,
    "logistics_performance": 100,
}


def validate_row_count(
    df: pd.DataFrame,
    dataset_name: str,
) -> None:
    """Validate that a dataset contains the expected number of rows."""

    if dataset_name not in EXPECTED_ROW_COUNTS:
        raise ValueError(f"Unknown dataset: {dataset_name}")

    expected = EXPECTED_ROW_COUNTS[dataset_name]
    actual = len(df)

    if actual != expected:
        raise ValueError(
            f"{dataset_name}: expected {expected} rows, got {actual}"
        )


def validate_no_nulls(
    df: pd.DataFrame,
    columns: list[str],
) -> None:
    """Validate that required columns contain no null values."""

    missing = [column for column in columns if column not in df.columns]

    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    null_counts = df[columns].isnull().sum()
    columns_with_nulls = null_counts[null_counts > 0]

    if not columns_with_nulls.empty:
        raise ValueError(
            f"Required columns contain null values: "
            f"{columns_with_nulls.to_dict()}"
        )


def validate_unique(
    df: pd.DataFrame,
    columns: list[str],
) -> None:
    """Validate that the specified columns contain unique values."""

    if df.duplicated(subset=columns).any():
        raise ValueError(
            f"Duplicate records found for columns: {columns}"
        )