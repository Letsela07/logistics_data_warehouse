-- create_schemas

-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Bronze Layer: Create Tables
-- =============================================
-- Purpose: Create raw data tables in bronze layer
-- All columns VARCHAR(255) to accept any raw data
-- No transformations at this stage
-- No data type restrictions or constraints
-- =============================================


-- =============================================
-- Step 1: Create Schemas
-- =============================================

-- Bronze: Raw data as-is from source
CREATE SCHEMA IF NOT EXISTS bronze;

-- Silver: Cleaned and standardized data
CREATE SCHEMA IF NOT EXISTS silver;

-- Gold: Business ready Star Schema
CREATE SCHEMA IF NOT EXISTS gold;


-- =============================================
-- Step 2: Drop Existing Bronze Tables
-- =============================================

DROP TABLE IF EXISTS bronze.customer;
DROP TABLE IF EXISTS bronze.shipment;
DROP TABLE IF EXISTS bronze.logistics_performance;


-- =============================================
-- Step 3: Create Bronze Tables
-- =============================================

-- Bronze Customer Table
-- Source: customer.csv
CREATE TABLE bronze.customer (
    customer_id VARCHAR(255),
    acquisition_date VARCHAR(255),
    acquisition_cost_usd VARCHAR(255),
    market_segment VARCHAR(255),
    supplier_id VARCHAR(255),
    order_id VARCHAR(255),
    order_date VARCHAR(255),
    order_value_usd VARCHAR(255),
    payment_date VARCHAR(255),
    satisfaction_score VARCHAR(255),
    support_tickets VARCHAR(255),
    lead_time_days VARCHAR(255)
);

-- Bronze Shipment Table
-- Source: shipment.csv
-- Note: customs_clearance_time_days contains mixed data
-- (float values AND text like On-Time/Delayed)
-- Will be split into 2 columns in Silver layer
CREATE TABLE bronze.shipment (
    shipment_id VARCHAR(255),
    type VARCHAR(255),
    date VARCHAR(255),
    product_category VARCHAR(255),
    origin VARCHAR(255),
    o_country VARCHAR(255),
    destination VARCHAR(255),
    d_country VARCHAR(255),
    value VARCHAR(255),
    freight_cost VARCHAR(255),
    customs_clearance_time_days VARCHAR(255),
    delivery_status VARCHAR(255)
);

-- Bronze Logistics Performance Table
-- Source: logistics_performance.csv
CREATE TABLE bronze.logistics_performance (
    date VARCHAR(255),
    region VARCHAR(255),
    carrier VARCHAR(255),
    shipments_processed VARCHAR(255),
    delay_hours_avg VARCHAR(255),
    fuel_price_usd_per_barrel VARCHAR(255),
    warehouse_utilization_percent VARCHAR(255),
    damage_claims_count VARCHAR(255)
);