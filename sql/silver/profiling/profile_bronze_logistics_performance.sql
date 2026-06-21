-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Bronze Profiling: logistics_performance table
-- Purpose: Understand data before transformation
-- =============================================


-- =============================================
-- 1. Overview
-- =============================================

SELECT COUNT(*) AS total_rows
FROM bronze.logistics_performance;

SELECT TOP 10 *
FROM bronze.logistics_performance;


-- =============================================
-- 2. date (performance_date in Silver)
-- Type: Date | Check: range, nulls, invalid, spaces, future
-- Result: 2024-06-01 to 2024-06-25, clean ✅
-- =============================================

SELECT 
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISDATE(date) = 0 THEN 1 ELSE 0 END) AS invalid_dates,
    SUM(CASE WHEN TRIM(date) != date THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN TRY_CAST(date AS DATE) > CAST(GETDATE() AS DATE) 
        THEN 1 ELSE 0 END) AS future_dates
FROM bronze.logistics_performance;


-- =============================================
-- 3. region
-- Type: Text | Check: distinct, nulls, spaces, empty
-- Result: 3 clean regions ✅
-- Asia-Pacific(25), Europe(25), North America(50)
-- =============================================

SELECT 
    region,
    COUNT(*) AS count
FROM bronze.logistics_performance
GROUP BY region
ORDER BY region;

SELECT 
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(region) != region THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN region = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.logistics_performance;


-- =============================================
-- 4. carrier
-- Type: Text | Check: distinct, nulls, spaces, empty
-- Result: Clean ✅
-- =============================================

SELECT 
    carrier,
    COUNT(*) AS count
FROM bronze.logistics_performance
GROUP BY carrier
ORDER BY carrier;

SELECT 
    SUM(CASE WHEN carrier IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(carrier) != carrier THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN carrier = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.logistics_performance;


-- =============================================
-- 5. shipments_processed
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- Result: Clean ✅
-- =============================================

SELECT 
    MIN(CAST(shipments_processed AS INT)) AS min_shipments,
    MAX(CAST(shipments_processed AS INT)) AS max_shipments,
    AVG(CAST(shipments_processed AS DECIMAL(10,2))) AS avg_shipments,
    SUM(CASE WHEN shipments_processed IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(shipments_processed) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(shipments_processed AS INT) < 0 
        THEN 1 ELSE 0 END) AS negative_values
FROM bronze.logistics_performance;


-- =============================================
-- 6. delay_hours_avg
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- Result: Clean ✅
-- =============================================

SELECT 
    MIN(CAST(delay_hours_avg AS DECIMAL(10,2))) AS min_delay,
    MAX(CAST(delay_hours_avg AS DECIMAL(10,2))) AS max_delay,
    AVG(CAST(delay_hours_avg AS DECIMAL(10,2))) AS avg_delay,
    SUM(CASE WHEN delay_hours_avg IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(delay_hours_avg) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(delay_hours_avg AS DECIMAL(10,2)) < 0 
        THEN 1 ELSE 0 END) AS negative_values
FROM bronze.logistics_performance;


-- =============================================
-- 7. fuel_price_usd_per_barrel
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- Result: 78.20 - 88.30, clean ✅
-- =============================================

SELECT 
    MIN(CAST(fuel_price_usd_per_barrel AS DECIMAL(10,2))) AS min_fuel,
    MAX(CAST(fuel_price_usd_per_barrel AS DECIMAL(10,2))) AS max_fuel,
    AVG(CAST(fuel_price_usd_per_barrel AS DECIMAL(10,2))) AS avg_fuel,
    SUM(CASE WHEN fuel_price_usd_per_barrel IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(fuel_price_usd_per_barrel) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(fuel_price_usd_per_barrel AS DECIMAL(10,2)) < 0 
        THEN 1 ELSE 0 END) AS negative_values
FROM bronze.logistics_performance;


-- =============================================
-- 8. warehouse_utilization_percent
-- Type: Number | Check: range 0-100, nulls, non-numeric
-- Result: Clean ✅
-- =============================================

SELECT 
    MIN(CAST(warehouse_utilization_percent AS INT)) AS min_utilization,
    MAX(CAST(warehouse_utilization_percent AS INT)) AS max_utilization,
    AVG(CAST(warehouse_utilization_percent AS DECIMAL(10,2))) AS avg_utilization,
    SUM(CASE WHEN warehouse_utilization_percent IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(warehouse_utilization_percent) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(warehouse_utilization_percent AS INT) < 0 
        THEN 1 ELSE 0 END) AS negative_values,
    SUM(CASE WHEN CAST(warehouse_utilization_percent AS INT) > 100 
        THEN 1 ELSE 0 END) AS over_100_percent
FROM bronze.logistics_performance;


-- =============================================
-- 9. damage_claims_count
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- Result: Clean ✅
-- =============================================

SELECT 
    MIN(CAST(damage_claims_count AS INT)) AS min_claims,
    MAX(CAST(damage_claims_count AS INT)) AS max_claims,
    AVG(CAST(damage_claims_count AS DECIMAL(10,2))) AS avg_claims,
    SUM(CASE WHEN damage_claims_count IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(damage_claims_count) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(damage_claims_count AS INT) < 0 
        THEN 1 ELSE 0 END) AS negative_values
FROM bronze.logistics_performance;


-- =============================================
-- 10. Cross column validation
-- Same date + region + carrier should not repeat
-- =============================================

SELECT 
    date, region, carrier,
    COUNT(*) AS count
FROM bronze.logistics_performance
GROUP BY date, region, carrier
HAVING COUNT(*) > 1;


-- =============================================
-- BRONZE LOGISTICS PROFILING SUMMARY
-- =============================================
-- date → clean, 2024-06-01 to 2024-06-25 ✅
-- region → 3 clean regions ✅
-- carrier → clean ✅
-- shipments_processed → clean ✅
-- delay_hours_avg → clean ✅
-- fuel_price_usd_per_barrel → clean, 78.20-88.30 ✅
-- warehouse_utilization_percent → clean ✅
-- damage_claims_count → clean ✅
--
-- Issues found: NONE
-- Cleanest table of the three!!
-- No transformations needed beyond data type casting
-- =============================================