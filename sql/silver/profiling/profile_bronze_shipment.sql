-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Bronze Profiling: shipment table
-- Purpose: Understand data before transformation
-- =============================================


-- =============================================
-- 1. Overview
-- =============================================

SELECT TOP 15 * FROM bronze.shipment;

SELECT COUNT(*) AS total_rows
FROM bronze.shipment;


-- =============================================
-- 2. shipment_id
-- Type: Text | Check: uniqueness, nulls, spaces
-- Result: 704 unique, clean ✅
-- =============================================

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT shipment_id) AS unique_ids,
    SUM(CASE WHEN shipment_id IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(shipment_id) != shipment_id THEN 1 ELSE 0 END) AS space_count
FROM bronze.shipment;


-- =============================================
-- 3. type
-- Type: Text | Check: distinct, nulls, spaces, empty
-- Result: Clean ✅
-- =============================================

SELECT 
    type,
    COUNT(*) AS count
FROM bronze.shipment
GROUP BY type
ORDER BY type;

SELECT 
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(type) != type THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN type = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.shipment;


-- =============================================
-- 4. date (shipment_date in Silver)
-- Type: Date | Check: range, nulls, spaces, future
-- Result: 2024-01-02 to 2025-12-31, clean ✅
-- =============================================

SELECT 
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISDATE(date) = 0 THEN 1 ELSE 0 END) AS invalid_dates,
    SUM(CASE WHEN TRIM(date) != date THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN TRY_CAST(date AS DATE) > CAST(GETDATE() AS DATE) 
        THEN 1 ELSE 0 END) AS future_dates
FROM bronze.shipment;


-- =============================================
-- 5. product_category
-- Type: Text | Check: distinct, nulls, spaces, empty
-- Result: 4 clean categories, clean ✅
-- Consumer Goods(194), Electronics(194),
-- Industrial Equipment(170), Textiles(146)
-- =============================================

SELECT 
    product_category,
    COUNT(*) AS count
FROM bronze.shipment
GROUP BY product_category
ORDER BY product_category;

SELECT 
    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(product_category) != product_category THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN product_category = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.shipment;


-- =============================================
-- 6. origin
-- Type: Text | Check: distinct, nulls, spaces, empty
-- Result: 15 cities, Mumbai dominant (364), clean ✅
-- =============================================

SELECT 
    origin,
    COUNT(*) AS total
FROM bronze.shipment
GROUP BY origin
ORDER BY origin;

SELECT 
    SUM(CASE WHEN origin IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(origin) != origin THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN origin = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.shipment;


-- =============================================
-- 7. o_country
-- Type: Text | Check: distinct, nulls, spaces, empty
-- ⚠️ ISSUE: ALL 704 rows have leading spaces
-- Fix: TRIM(o_country) in Silver
-- =============================================

SELECT 
    o_country,
    COUNT(*) AS total
FROM bronze.shipment
GROUP BY o_country
ORDER BY o_country;

SELECT 
    SUM(CASE WHEN o_country IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(o_country) != o_country THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN o_country = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.shipment;


-- =============================================
-- 8. destination
-- Type: Text | Check: distinct, nulls, spaces, empty
-- Result: Clean ✅
-- =============================================

SELECT 
    destination,
    COUNT(*) AS total
FROM bronze.shipment
GROUP BY destination
ORDER BY destination;

SELECT 
    SUM(CASE WHEN destination IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(destination) != destination THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN destination = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.shipment;


-- =============================================
-- 9. d_country
-- Type: Text | Check: distinct, nulls, spaces, empty, numeric
-- ⚠️ ISSUE 1: 680 rows have leading spaces
-- ⚠️ ISSUE 2: 24 numeric values in country column
--            (malformed rows from source system bug)
-- Fix: TRIM + handle numeric values in Silver
-- =============================================

SELECT 
    d_country,
    COUNT(*) AS total
FROM bronze.shipment
GROUP BY d_country
ORDER BY d_country;

SELECT 
    SUM(CASE WHEN d_country IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(d_country) != d_country THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN d_country = '' THEN 1 ELSE 0 END) AS empty_count,
    SUM(CASE WHEN ISNUMERIC(d_country) = 1 THEN 1 ELSE 0 END) AS numeric_in_country
FROM bronze.shipment;


-- =============================================
-- 10. value (shipment_value in Silver)
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- Result: 3250-415000, clean ✅
-- =============================================

SELECT 
    MIN(CAST(value AS INT)) AS min_value,
    MAX(CAST(value AS INT)) AS max_value,
    AVG(CAST(value AS DECIMAL(10,2))) AS avg_value,
    SUM(CASE WHEN value IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(value) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(value AS INT) < 0 THEN 1 ELSE 0 END) AS negative_values
FROM bronze.shipment;


-- =============================================
-- 11. freight_cost
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- Result: 2.20-20750, clean ✅
-- =============================================

SELECT 
    MIN(CAST(freight_cost AS DECIMAL(10,2))) AS min_freight,
    MAX(CAST(freight_cost AS DECIMAL(10,2))) AS max_freight,
    AVG(CAST(freight_cost AS DECIMAL(10,2))) AS avg_freight,
    SUM(CASE WHEN freight_cost IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(freight_cost) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(freight_cost AS DECIMAL(10,2)) < 0 
        THEN 1 ELSE 0 END) AS negative_values
FROM bronze.shipment;


-- =============================================
-- 12. customs_clearance_time_days
-- Type: Mixed! Numbers AND text
-- ⚠️ ISSUE: 24 non-numeric values found
--   - 'On-Time' in 18 rows
--   - 'Delayed' in 6 rows
-- Numeric range: 1.50 - 5.90 days
-- Fix: CASE WHEN ISNUMERIC = 1 THEN CAST
--      ELSE NULL
-- =============================================

SELECT 
    SUM(CASE WHEN customs_clearance_time_days IS NULL 
        THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(customs_clearance_time_days) = 1 
        THEN 1 ELSE 0 END) AS numeric_count,
    SUM(CASE WHEN ISNUMERIC(customs_clearance_time_days) = 0 
        THEN 1 ELSE 0 END) AS non_numeric_count,
    MIN(CASE WHEN ISNUMERIC(customs_clearance_time_days) = 1 
        THEN CAST(customs_clearance_time_days AS DECIMAL(10,2)) END) AS min_days,
    MAX(CASE WHEN ISNUMERIC(customs_clearance_time_days) = 1 
        THEN CAST(customs_clearance_time_days AS DECIMAL(10,2)) END) AS max_days
FROM bronze.shipment;

-- Non-numeric values investigation
SELECT DISTINCT customs_clearance_time_days
FROM bronze.shipment
WHERE ISNUMERIC(customs_clearance_time_days) = 0;


-- =============================================
-- 13. delivery_status
-- Type: Text | Check: distinct, nulls, spaces, invalid
-- ⚠️ ISSUE: 24 invalid values (malformed rows)
--   Valid: On-Time (574), Delayed (106)
--   Invalid: 24 rows contain full row data
-- Fix: SET to NULL where NOT IN ('On-Time','Delayed')
-- =============================================

SELECT 
    delivery_status,
    COUNT(*) AS total
FROM bronze.shipment
GROUP BY delivery_status
ORDER BY delivery_status;

SELECT 
    SUM(CASE WHEN delivery_status IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(delivery_status) != delivery_status 
        THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN delivery_status = '' THEN 1 ELSE 0 END) AS empty_count,
    SUM(CASE WHEN delivery_status NOT IN ('On-Time', 'Delayed') 
        THEN 1 ELSE 0 END) AS invalid_status
FROM bronze.shipment;


-- =============================================
-- BRONZE SHIPMENT PROFILING SUMMARY
-- =============================================
-- shipment_id   → clean, 704 unique ✅
-- type          → clean ✅
-- date          → clean, 2024-2025 ✅
-- product_category → 4 clean categories ✅
-- origin        → 15 clean cities ✅
-- o_country     → ⚠️ ALL 704 rows have leading spaces
-- destination   → clean ✅
-- d_country     → ⚠️ spaces + 24 numeric values
-- value         → clean, 3250-415000 ✅
-- freight_cost  → clean, 2.20-20750 ✅
-- customs_clearance_time_days → ⚠️ 24 non-numeric values
-- delivery_status → ⚠️ 24 invalid values
--
-- Issues to fix in Silver:
-- 1. o_country → TRIM
-- 2. d_country → TRIM + handle numeric values
-- 3. customs_clearance_time_days → CASE WHEN ISNUMERIC
-- 4. delivery_status → SET invalid to NULL
-- =============================================