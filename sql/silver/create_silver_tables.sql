-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Silver Layer: Load Cleaned Data
-- =============================================
-- Purpose: Extract from Bronze, clean and load
--          into Silver tables
-- Cleaning applied:
--   - CAST for data type conversions
--   - TRY_CAST for safe conversions on dirty data
--   - TRIM to remove leading/trailing spaces
--   - CASE WHEN ISNUMERIC for mixed data columns
--   - LEFT() to handle malformed rows
-- =============================================


-- =============================================
-- Step 1: Load Silver Customer
-- Cleaning: CAST all columns to proper types
-- No nulls found, no spaces, no mixed data
-- =============================================

INSERT INTO silver.customer
SELECT
    customer_id,
    CAST(acquisition_date    AS DATE),
    CAST(acquisition_cost_usd AS DECIMAL(10,2)),
    market_segment,
    supplier_id,
    order_id,
    CAST(order_date          AS DATE),
    CAST(order_value_usd     AS DECIMAL(10,2)),
    CAST(payment_date        AS DATE),
    CAST(satisfaction_score  AS INT),
    CAST(support_tickets     AS INT),
    CAST(lead_time_days      AS INT)
FROM bronze.customer;

-- Verify Customer Load
SELECT COUNT(*) AS silver_customer_count
FROM silver.customer;
-- Expected: 750


-- =============================================
-- Step 2: Load Silver Shipment
-- Cleaning applied:
--   - TRIM on o_country, d_country (leading spaces found)
--   - TRY_CAST for safe date and value conversion
--   - CASE WHEN ISNUMERIC for customs_clearance_time_days
--     (contains mixed data - floats AND text)
--   - LEFT(50) on delivery_status
--     (malformed row SHP-2024-0010 found)
-- Data Quality Issues:
--   - Every 9th row: delivery status in wrong column
--   - Every 10th row: entire row malformed
--   - Root cause: Suspected source system export bug
-- =============================================

INSERT INTO silver.shipment
SELECT
    shipment_id,
    type,
    TRY_CAST(date            AS DATE),
    product_category,
    origin,
    TRIM(o_country),
    destination,
    TRIM(d_country),
    TRY_CAST(value           AS INT),
    TRY_CAST(freight_cost    AS DECIMAL(10,2)),
    CASE
        WHEN ISNUMERIC(customs_clearance_time_days) = 1
            THEN CAST(customs_clearance_time_days AS DECIMAL(10,2))
        ELSE NULL
    END,
    LEFT(delivery_status, 50)
FROM bronze.shipment;

-- Verify Shipment Load
SELECT COUNT(*) AS silver_shipment_count
FROM silver.shipment;
-- Expected: 704


-- =============================================
-- Step 3: Load Silver Logistics Performance
-- Cleaning: CAST all columns to proper types
-- No nulls, no spaces, no mixed data found
-- date renamed to performance_date
-- =============================================

INSERT INTO silver.logistics_performance
SELECT
    CAST(date                          AS DATE),
    region,
    carrier,
    CAST(shipments_processed           AS INT),
    CAST(delay_hours_avg               AS DECIMAL(10,2)),
    CAST(fuel_price_usd_per_barrel     AS DECIMAL(10,2)),
    CAST(warehouse_utilization_percent AS INT),
    CAST(damage_claims_count           AS INT)
FROM bronze.logistics_performance;

-- Verify Logistics Performance Load
SELECT COUNT(*) AS silver_logistics_count
FROM silver.logistics_performance;
-- Expected: 100


-- =============================================
-- Step 4: Final Row Count Validation
-- Bronze vs Silver counts must match!
-- =============================================

SELECT 'bronze.customer'              AS table_name,
        COUNT(*)                      AS row_count
FROM bronze.customer
UNION ALL
SELECT 'silver.customer',               COUNT(*)
FROM silver.customer
UNION ALL
SELECT 'bronze.shipment',               COUNT(*)
FROM bronze.shipment
UNION ALL
SELECT 'silver.shipment',               COUNT(*)
FROM silver.shipment
UNION ALL
SELECT 'bronze.logistics_performance',  COUNT(*)
FROM bronze.logistics_performance
UNION ALL
SELECT 'silver.logistics_performance',  COUNT(*)
FROM silver.logistics_performance;

-- Expected Results:
-- bronze.customer              → 750
-- silver.customer              → 750
-- bronze.shipment              → 704
-- silver.shipment              → 704
-- bronze.logistics_performance → 100
-- silver.logistics_performance → 100