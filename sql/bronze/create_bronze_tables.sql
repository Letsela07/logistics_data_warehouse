-- create_schemas

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;

-- create_bronze_customer

CREATE TABLE bronze.customer (
    customer_id VARCHAR(50),
    acquisition_date DATE,
    acquisition_cost_usd DECIMAL(10,2),
    market_segment VARCHAR(100),
    supplier_id VARCHAR(50),
    order_id VARCHAR(50),
    order_date DATE,
    order_value_usd DECIMAL(10,2),
    payment_date DATE,
    satisfaction_score INT,
    support_tickets INT,
    lead_time_days INT
);


-- create_bronze_shipment

CREATE TABLE bronze.shipment (
    shipment_id VARCHAR(50),
    type VARCHAR(50),
    date DATE,
    product_category VARCHAR(100),
    origin VARCHAR(100),
    o_country VARCHAR(100),
    destination VARCHAR(100),
    d_country VARCHAR(100),
    value DECIMAL(10,2),
    freight_cost DECIMAL(10,2),
    customs_clearance_time_days DECIMAL(10,2),
    delivery_status VARCHAR(50)
);


-- create_bronze_logistics_performance

CREATE TABLE bronze.logistics_performance (
    date DATE,
    region VARCHAR(100),
    carrier VARCHAR(100),
    shipments_processed INT,
    delay_hours_avg DECIMAL(10,2),
    fuel_price_usd_per_barrel DECIMAL(10,2),
    warehouse_utilization_percent DECIMAL(5,2),
    damage_claims_count INT
);