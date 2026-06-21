-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Silver Layer: Create Tables
-- =============================================
-- Purpose: Create cleaned and typed silver tables
-- Approach: Profile Bronze first, transform based
--           on evidence only
-- =============================================


-- =============================================
-- Step 1: Drop Existing Silver Tables
-- =============================================

DROP TABLE IF EXISTS silver.customer;
DROP TABLE IF EXISTS silver.shipment;
DROP TABLE IF EXISTS silver.logistics_performance;


-- =============================================
-- Step 2: Create Silver Customer Table
-- Source: bronze.customer
-- Changes:
--   - All dates converted from VARCHAR to DATE
--   - acquisition_cost_usd → DECIMAL(10,2)
--   - order_value_usd → DECIMAL(10,2)
--   - satisfaction_score → INT
--   - support_tickets → INT
--   - lead_time_days → INT
--   - Added is_future_order derived column
--     (403 future order dates found in profiling)
-- No TRIM needed: profiling showed 0 spaces
-- =============================================

CREATE TABLE silver.customer (
    customer_id             NVARCHAR(50),
    acquisition_date        DATE,
    acquisition_cost_usd    DECIMAL(10,2),
    market_segment          NVARCHAR(100),
    supplier_id             NVARCHAR(50),
    order_id                NVARCHAR(50),
    order_date              DATE,
    order_value_usd         DECIMAL(10,2),
    payment_date            DATE,
    satisfaction_score      INT,
    support_tickets         INT,
    lead_time_days          INT,
    is_future_order         INT  -- 1=future order, 0=current order
);


-- =============================================
-- Step 3: Create Silver Shipment Table
-- Source: bronze.shipment
-- Changes:
--   - type → shipment_type (reserved word)
--   - date → shipment_date (reserved word)
--   - value → shipment_value (reserved word)
--   - o_country → origin_country (clarity)
--   - d_country → destination_country (clarity)
--   - customs_clearance_time_days → customs_clearance_days
--   - shipment_date converted to DATE
--   - shipment_value converted to INT
--   - freight_cost converted to DECIMAL(10,2)
--   - customs_clearance_days converted to DECIMAL(10,2)
-- Issues found in profiling:
--   - o_country: ALL 704 rows have leading spaces
--   - d_country: spaces + 24 numeric values
--   - customs_clearance_time_days: 24 non-numeric values
--   - delivery_status: 24 invalid values
-- =============================================

CREATE TABLE silver.shipment (
    shipment_id             NVARCHAR(50),
    shipment_type           NVARCHAR(50),
    shipment_date           DATE,
    product_category        NVARCHAR(100),
    origin                  NVARCHAR(100),
    origin_country          NVARCHAR(100),
    destination             NVARCHAR(100),
    destination_country     NVARCHAR(100),
    shipment_value          INT,
    freight_cost            DECIMAL(10,2),
    customs_clearance_days  DECIMAL(10,2),
    delivery_status         NVARCHAR(50)
);


-- =============================================
-- Step 4: Create Silver Logistics Performance Table
-- Source: bronze.logistics_performance
-- Changes:
--   - date → performance_date (reserved word)
--   - performance_date converted to DATE
--   - shipments_processed converted to INT
--   - delay_hours_avg converted to DECIMAL(10,2)
--   - fuel_price_usd_per_barrel converted to DECIMAL(10,2)
--   - warehouse_utilization_percent converted to INT
--   - damage_claims_count converted to INT
-- No issues found in profiling: cleanest table ✅
-- =============================================

CREATE TABLE silver.logistics_performance (
    performance_date                DATE,
    region                          NVARCHAR(50),
    carrier                         NVARCHAR(50),
    shipments_processed             INT,
    delay_hours_avg                 DECIMAL(10,2),
    fuel_price_usd_per_barrel       DECIMAL(10,2),
    warehouse_utilization_percent   INT,
    damage_claims_count             INT
);


-- =============================================
-- Step 5: Verify Tables Created
-- =============================================

SELECT 
    table_schema, 
    table_name
FROM information_schema.tables
WHERE table_schema IN ('bronze', 'silver')
ORDER BY table_schema, table_name;