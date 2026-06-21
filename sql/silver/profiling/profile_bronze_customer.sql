-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Bronze Profiling: customer table
-- Purpose: Understand data before transformation
-- =============================================


-- =============================================
-- 1. Overview
-- =============================================

SELECT COUNT(*) AS total_rows
FROM bronze.customer;

SELECT TOP 10 * 
FROM bronze.customer;


-- =============================================
-- 2. customer_id
-- Type: Text | Check: uniqueness, nulls, spaces
-- =============================================

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_ids,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(customer_id) != customer_id THEN 1 ELSE 0 END) AS space_count
FROM bronze.customer;


-- =============================================
-- 3. acquisition_date
-- Type: Date | Check: range, nulls, invalid, future, spaces
-- =============================================

SELECT 
    MIN(acquisition_date) AS earliest_date,
    MAX(acquisition_date) AS latest_date,
    SUM(CASE WHEN acquisition_date IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISDATE(acquisition_date) = 0 THEN 1 ELSE 0 END) AS invalid_dates,
    SUM(CASE WHEN TRIM(acquisition_date) != acquisition_date THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN CAST(acquisition_date AS DATE) > GETDATE() THEN 1 ELSE 0 END) AS future_dates
FROM bronze.customer;


-- =============================================
-- 4. acquisition_cost_usd
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- =============================================

SELECT 
    MIN(CAST(acquisition_cost_usd AS DECIMAL(10,2))) AS min_cost,
    MAX(CAST(acquisition_cost_usd AS DECIMAL(10,2))) AS max_cost,
    AVG(CAST(acquisition_cost_usd AS DECIMAL(10,2))) AS avg_cost,
    SUM(CASE WHEN acquisition_cost_usd IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(acquisition_cost_usd) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(acquisition_cost_usd AS DECIMAL(10,2)) < 0 THEN 1 ELSE 0 END) AS negative_values
FROM bronze.customer;


-- =============================================
-- 5. market_segment
-- Type: Text | Check: distinct values, nulls, spaces
-- =============================================

SELECT 
    market_segment,
    COUNT(*) AS count
FROM bronze.customer
GROUP BY market_segment
ORDER BY market_segment;

SELECT 
    SUM(CASE WHEN market_segment IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(market_segment) != market_segment THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN market_segment = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.customer;


-- =============================================
-- 6. supplier_id
-- Type: Text | Check: distinct values, nulls, spaces
-- =============================================

SELECT 
    supplier_id,
    COUNT(*) AS count
FROM bronze.customer
GROUP BY supplier_id
ORDER BY supplier_id;

SELECT 
    COUNT(DISTINCT supplier_id) AS unique_suppliers,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(supplier_id) != supplier_id THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN supplier_id = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.customer;


-- =============================================
-- 7. order_id
-- Type: Text | Check: uniqueness, nulls, spaces
-- =============================================

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN TRIM(order_id) != order_id THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN order_id = '' THEN 1 ELSE 0 END) AS empty_count
FROM bronze.customer;


-- =============================================
-- 8. order_date
-- Type: Date | Check: range, nulls, invalid, future, spaces
-- =============================================

SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISDATE(order_date) = 0 THEN 1 ELSE 0 END) AS invalid_dates,
    SUM(CASE WHEN TRIM(order_date) != order_date THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN CAST(order_date AS DATE) > GETDATE() THEN 1 ELSE 0 END) AS future_dates
FROM bronze.customer;

-- Distribution by year
SELECT 
    YEAR(CAST(order_date AS DATE)) AS order_year,
    COUNT(*) AS row_count
FROM bronze.customer
GROUP BY YEAR(CAST(order_date AS DATE))
ORDER BY order_year;


-- =============================================
-- 9. order_value_usd
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- =============================================

SELECT 
    MIN(CAST(order_value_usd AS DECIMAL(10,2))) AS min_value,
    MAX(CAST(order_value_usd AS DECIMAL(10,2))) AS max_value,
    AVG(CAST(order_value_usd AS DECIMAL(10,2))) AS avg_value,
    SUM(CASE WHEN order_value_usd IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(order_value_usd) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(order_value_usd AS DECIMAL(10,2)) < 0 THEN 1 ELSE 0 END) AS negative_values
FROM bronze.customer;


-- =============================================
-- 10. payment_date
-- Type: Date | Check: range, nulls, invalid, future, spaces
-- =============================================

SELECT 
    MIN(payment_date) AS earliest_payment,
    MAX(payment_date) AS latest_payment,
    SUM(CASE WHEN payment_date IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISDATE(payment_date) = 0 THEN 1 ELSE 0 END) AS invalid_dates,
    SUM(CASE WHEN TRIM(payment_date) != payment_date THEN 1 ELSE 0 END) AS space_count,
    SUM(CASE WHEN CAST(payment_date AS DATE) > GETDATE() THEN 1 ELSE 0 END) AS future_dates
FROM bronze.customer;


-- =============================================
-- 11. satisfaction_score
-- Type: Number | Check: range 1-5, nulls, non-numeric
-- =============================================

SELECT 
    MIN(CAST(satisfaction_score AS INT)) AS min_score,
    MAX(CAST(satisfaction_score AS INT)) AS max_score,
    AVG(CAST(satisfaction_score AS DECIMAL(10,2))) AS avg_score,
    SUM(CASE WHEN satisfaction_score IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(satisfaction_score) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(satisfaction_score AS INT) NOT IN (1,2,3,4,5) 
        THEN 1 ELSE 0 END) AS out_of_range
FROM bronze.customer;


-- =============================================
-- 12. support_tickets
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- =============================================

SELECT 
    MIN(CAST(support_tickets AS INT)) AS min_tickets,
    MAX(CAST(support_tickets AS INT)) AS max_tickets,
    AVG(CAST(support_tickets AS DECIMAL(10,2))) AS avg_tickets,
    SUM(CASE WHEN support_tickets IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(support_tickets) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(support_tickets AS INT) < 0 THEN 1 ELSE 0 END) AS negative_values
FROM bronze.customer;


-- =============================================
-- 13. lead_time_days
-- Type: Number | Check: range, nulls, non-numeric, negatives
-- =============================================

SELECT 
    MIN(CAST(lead_time_days AS INT)) AS min_days,
    MAX(CAST(lead_time_days AS INT)) AS max_days,
    AVG(CAST(lead_time_days AS DECIMAL(10,2))) AS avg_days,
    SUM(CASE WHEN lead_time_days IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN ISNUMERIC(lead_time_days) = 0 THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN CAST(lead_time_days AS INT) < 0 THEN 1 ELSE 0 END) AS negative_values
FROM bronze.customer;


-- =============================================
-- 14. Cross column validation
-- payment_date should be after order_date
-- =============================================

SELECT COUNT(*) AS payment_before_order
FROM bronze.customer
WHERE CAST(payment_date AS DATE) < CAST(order_date AS DATE);


-- =============================================
-- 15. Overall spaces check - all text columns
-- =============================================

SELECT 
    SUM(CASE WHEN TRIM(customer_id) != customer_id THEN 1 ELSE 0 END) AS customer_id_spaces,
    SUM(CASE WHEN TRIM(acquisition_date) != acquisition_date THEN 1 ELSE 0 END) AS acq_date_spaces,
    SUM(CASE WHEN TRIM(market_segment) != market_segment THEN 1 ELSE 0 END) AS market_segment_spaces,
    SUM(CASE WHEN TRIM(supplier_id) != supplier_id THEN 1 ELSE 0 END) AS supplier_id_spaces,
    SUM(CASE WHEN TRIM(order_id) != order_id THEN 1 ELSE 0 END) AS order_id_spaces,
    SUM(CASE WHEN TRIM(order_date) != order_date THEN 1 ELSE 0 END) AS order_date_spaces,
    SUM(CASE WHEN TRIM(payment_date) != payment_date THEN 1 ELSE 0 END) AS payment_date_spaces
FROM bronze.customer;