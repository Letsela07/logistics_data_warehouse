-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Silver Layer: Load Cleaned Data
-- =============================================
-- Purpose: Extract from Bronze, clean and load
--          into Silver tables
-- Approach: Transformations based on profiling
--           evidence only - not assumptions
-- =============================================


-- =============================================
-- Step 1: Load Silver Customer
-- =============================================
-- Transformations applied:
--   - SELECT DISTINCT → remove duplicates
--   - CAST dates → DATE type
--   - CAST numbers → proper types
--   - is_future_order flag → 403 future dates found
-- NOT applied:
--   - TRIM → profiling showed 0 spaces
-- =============================================

TRUNCATE TABLE silver.customer;

INSERT INTO silver.customer
SELECT DISTINCT
    customer_id,
    CAST(acquisition_date AS DATE),
    CAST(acquisition_cost_usd AS DECIMAL(10,2)),
    market_segment,
    supplier_id,
    order_id,
    CAST(order_date AS DATE),
    CAST(order_value_usd AS DECIMAL(10,2)),
    CAST(payment_date AS DATE),
    CAST(satisfaction_score AS INT),
    CAST(support_tickets AS INT),
    CAST(lead_time_days AS INT),
    CASE 
        WHEN CAST(order_date AS DATE) > GETDATE() THEN 1
        ELSE 0
    END AS is_future_order
FROM bronze.customer;

-- Verify Customer Load
SELECT COUNT(*) AS silver_customer_count
FROM silver.customer;
-- Expected: 750


-- =============================================
-- Step 2: Load Silver Shipment
-- =============================================
-- Transformations applied:
--   - SELECT DISTINCT → remove duplicates
--   - TRIM(o_country) → 704 rows had leading spaces
--   - TRIM(d_country) → 680 rows had leading spaces
--   - CASE WHEN ISNUMERIC(d_country) → 24 numeric values
--   - TRY_CAST(date AS DATE) → safe date conversion
--   - TRY_CAST(value AS INT) → safe conversion
--   - TRY_CAST(freight_cost AS DECIMAL) → safe conversion
--   - CASE WHEN ISNUMERIC(customs_clearance_time_days)
--     → 24 non-numeric values found
--   - CASE WHEN delivery_status NOT IN → 24 invalid values
-- =============================================

TRUNCATE TABLE silver.shipment;

INSERT INTO silver.shipment
SELECT DISTINCT
    shipment_id,
    type,
    TRY_CAST(date AS DATE),
    product_category,
    origin,
    TRIM(o_country),
    destination,
    CASE
        WHEN ISNUMERIC(d_country) = 1 THEN NULL
        ELSE TRIM(d_country)
    END,
    TRY_CAST(value AS INT),
    TRY_CAST(freight_cost AS DECIMAL(10,2)),
    CASE
        WHEN ISNUMERIC(customs_clearance_time_days) = 1
            THEN CAST(customs_clearance_time_days AS DECIMAL(10,2))
        ELSE NULL
    END,
    CASE
        WHEN delivery_status IN ('On-Time', 'Delayed')
            THEN delivery_status
        ELSE NULL
    END
FROM bronze.shipment;

-- Verify Shipment Load
SELECT COUNT(*) AS silver_shipment_count
FROM silver.shipment;
-- Expected: 704


-- =============================================
-- Step 3: Load Silver Logistics Performance
-- =============================================
-- Transformations applied:
--   - SELECT DISTINCT → remove duplicates
--   - CAST date → DATE type
--   - CAST numbers → proper types
-- NOT applied:
--   - TRIM → profiling showed 0 spaces
--   - No issues found in profiling
-- =============================================

TRUNCATE TABLE silver.logistics_performance;

INSERT INTO silver.logistics_performance
SELECT DISTINCT
    CAST(date AS DATE),
    region,
    carrier,
    CAST(shipments_processed AS INT),
    CAST(delay_hours_avg AS DECIMAL(10,2)),
    CAST(fuel_price_usd_per_barrel AS DECIMAL(10,2)),
    CAST(warehouse_utilization_percent AS INT),
    CAST(damage_claims_count AS INT)
FROM bronze.logistics_performance;

-- Verify Logistics Performance Load
SELECT COUNT(*) AS silver_logistics_count
FROM silver.logistics_performance;
-- Expected: 100


-- =============================================
-- Step 4: Final Row Count Validation
-- Bronze vs Silver counts must match!
-- =============================================

SELECT 
    'bronze.customer' AS table_name,
    COUNT(*) AS row_count
FROM bronze.customer
UNION ALL
SELECT 'silver.customer', COUNT(*)
FROM silver.customer
UNION ALL
SELECT 'bronze.shipment', COUNT(*)
FROM bronze.shipment
UNION ALL
SELECT 'silver.shipment', COUNT(*)
FROM silver.shipment
UNION ALL
SELECT 'bronze.logistics_performance', COUNT(*)
FROM bronze.logistics_performance
UNION ALL
SELECT 'silver.logistics_performance', COUNT(*)
FROM silver.logistics_performance;

-- Expected Results:
-- bronze.customer              → 750
-- silver.customer              → 750
-- bronze.shipment              → 704
-- silver.shipment              → 704
-- bronze.logistics_performance → 100
-- silver.logistics_performance → 100