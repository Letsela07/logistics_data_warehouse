-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Gold Layer: Create All Views
-- =============================================
-- Purpose: Create business ready Star Schema
--          using views from Silver layer
-- Object type: VIEWS (no data storage)
-- =============================================


-- =============================================
-- DIMENSION VIEWS
-- =============================================


-- =============================================
-- dim_location
-- Source: silver.shipment
-- Combines origin and destination locations
-- =============================================

CREATE OR ALTER VIEW gold.dim_location AS
SELECT
    ROW_NUMBER() OVER (ORDER BY city, country) AS location_id,
    city,
    country
FROM (
    SELECT DISTINCT
        origin AS city,
        TRIM(origin_country) AS country
    FROM silver.shipment
    WHERE origin IS NOT NULL
    UNION
    SELECT DISTINCT
        destination AS city,
        TRIM(destination_country) AS country
    FROM silver.shipment
    WHERE destination IS NOT NULL
) AS locations;


-- =============================================
-- dim_product
-- Source: silver.shipment
-- =============================================

CREATE OR ALTER VIEW gold.dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_category) AS product_id,
    product_category
FROM (
    SELECT DISTINCT product_category
    FROM silver.shipment
    WHERE product_category IS NOT NULL
) AS products;


-- =============================================
-- dim_shipment_type
-- Source: silver.shipment
-- =============================================

CREATE OR ALTER VIEW gold.dim_shipment_type AS
SELECT
    ROW_NUMBER() OVER (ORDER BY shipment_type) AS shipment_type_id,
    shipment_type
FROM (
    SELECT DISTINCT shipment_type
    FROM silver.shipment
    WHERE shipment_type IS NOT NULL
) AS shipment_types;


-- =============================================
-- dim_delivery_status
-- Source: silver.shipment
-- =============================================

CREATE OR ALTER VIEW gold.dim_delivery_status AS
SELECT
    ROW_NUMBER() OVER (ORDER BY delivery_status) AS status_id,
    delivery_status
FROM (
    SELECT DISTINCT delivery_status
    FROM silver.shipment
    WHERE delivery_status IS NOT NULL
) AS statuses;


-- =============================================
-- dim_market_segment
-- Source: silver.customer
-- =============================================

CREATE OR ALTER VIEW gold.dim_market_segment AS
SELECT
    ROW_NUMBER() OVER (ORDER BY market_segment) AS segment_id,
    market_segment
FROM (
    SELECT DISTINCT market_segment
    FROM silver.customer
    WHERE market_segment IS NOT NULL
) AS segments;


-- =============================================
-- dim_supplier
-- Source: silver.customer
-- =============================================

CREATE OR ALTER VIEW gold.dim_supplier AS
SELECT
    ROW_NUMBER() OVER (ORDER BY supplier_id) AS supplier_key,
    supplier_id
FROM (
    SELECT DISTINCT supplier_id
    FROM silver.customer
    WHERE supplier_id IS NOT NULL
) AS suppliers;


-- =============================================
-- dim_customer
-- Source: silver.customer
-- =============================================

CREATE OR ALTER VIEW gold.dim_customer AS
SELECT
    customer_id,
    market_segment,
    acquisition_date,
    acquisition_cost_usd
FROM silver.customer;


-- =============================================
-- dim_carrier
-- Source: silver.logistics_performance
-- =============================================

CREATE OR ALTER VIEW gold.dim_carrier AS
SELECT
    ROW_NUMBER() OVER (ORDER BY carrier) AS carrier_id,
    carrier
FROM (
    SELECT DISTINCT carrier
    FROM silver.logistics_performance
    WHERE carrier IS NOT NULL
) AS carriers;


-- =============================================
-- dim_region
-- Source: silver.logistics_performance
-- =============================================

CREATE OR ALTER VIEW gold.dim_region AS
SELECT
    ROW_NUMBER() OVER (ORDER BY region) AS region_id,
    region
FROM (
    SELECT DISTINCT region
    FROM silver.logistics_performance
    WHERE region IS NOT NULL
) AS regions;


-- =============================================
-- dim_date
-- Source: All Silver tables
-- Combines all dates into one dimension
-- =============================================

CREATE OR ALTER VIEW gold.dim_date AS
SELECT DISTINCT
    full_date,
    YEAR(full_date) AS year,
    MONTH(full_date) AS month,
    DATEPART(QUARTER, full_date) AS quarter
FROM (
    SELECT CAST(acquisition_date AS DATE) AS full_date
    FROM silver.customer
    UNION
    SELECT CAST(order_date AS DATE)
    FROM silver.customer
    UNION
    SELECT CAST(payment_date AS DATE)
    FROM silver.customer
    UNION
    SELECT CAST(shipment_date AS DATE)
    FROM silver.shipment
    UNION
    SELECT CAST(performance_date AS DATE)
    FROM silver.logistics_performance
) AS all_dates
WHERE full_date IS NOT NULL;


-- =============================================
-- FACT VIEWS
-- =============================================


-- =============================================
-- fact_shipments
-- Source: silver.shipment
-- Joins: dim_date, dim_product, dim_location,
--        dim_shipment_type, dim_delivery_status
-- =============================================

CREATE OR ALTER VIEW gold.fact_shipments AS
SELECT
    -- Primary Key
    s.shipment_id,

    -- Foreign Keys
    d.full_date AS shipment_date,
    p.product_id,
    ol.location_id AS origin_location_id,
    dl.location_id AS destination_location_id,
    st.shipment_type_id,
    ds.status_id,

    -- Measures
    s.shipment_value,
    s.freight_cost,
    s.customs_clearance_days

FROM silver.shipment s

LEFT JOIN gold.dim_date d
    ON s.shipment_date = d.full_date

LEFT JOIN gold.dim_product p
    ON s.product_category = p.product_category

LEFT JOIN gold.dim_location ol
    ON s.origin = ol.city
    AND s.origin_country = ol.country

LEFT JOIN gold.dim_location dl
    ON s.destination = dl.city
    AND s.destination_country = dl.country

LEFT JOIN gold.dim_shipment_type st
    ON s.shipment_type = st.shipment_type

LEFT JOIN gold.dim_delivery_status ds
    ON s.delivery_status = ds.delivery_status;


-- =============================================
-- fact_orders
-- Source: silver.customer
-- Joins: dim_customer, dim_date, dim_supplier
-- =============================================

CREATE OR ALTER VIEW gold.fact_orders AS
SELECT
    -- Primary Key
    c.order_id,

    -- Foreign Keys
    cs.customer_id,
    sp.supplier_id,
    acq.full_date AS acquisition_date,
    ord.full_date AS order_date,
    pay.full_date AS payment_date,

    -- Measures
    c.acquisition_cost_usd,
    c.order_value_usd,
    c.satisfaction_score,
    c.support_tickets,
    c.lead_time_days,
    c.is_future_order

FROM silver.customer c

LEFT JOIN gold.dim_customer cs
    ON c.customer_id = cs.customer_id

LEFT JOIN gold.dim_date acq
    ON c.acquisition_date = acq.full_date

LEFT JOIN gold.dim_date ord
    ON c.order_date = ord.full_date

LEFT JOIN gold.dim_date pay
    ON c.payment_date = pay.full_date

LEFT JOIN gold.dim_supplier sp
    ON c.supplier_id = sp.supplier_id;


-- =============================================
-- fact_logistics_performance
-- Source: silver.logistics_performance
-- Joins: dim_date, dim_region, dim_carrier
-- =============================================

CREATE OR ALTER VIEW gold.fact_logistics_performance AS
SELECT
    -- Surrogate Primary Key
    ROW_NUMBER() OVER (
        ORDER BY lp.performance_date,
                 lp.region,
                 lp.carrier
    ) AS performance_id,

    -- Foreign Keys
    d.full_date AS performance_date,
    r.region_id,
    cr.carrier_id,

    -- Measures
    lp.shipments_processed,
    lp.delay_hours_avg,
    lp.fuel_price_usd_per_barrel,
    lp.warehouse_utilization_percent,
    lp.damage_claims_count

FROM silver.logistics_performance lp

LEFT JOIN gold.dim_date d
    ON lp.performance_date = d.full_date

LEFT JOIN gold.dim_region r
    ON lp.region = r.region

LEFT JOIN gold.dim_carrier cr
    ON lp.carrier = cr.carrier;


-- =============================================
-- VERIFICATION
-- =============================================

-- Verify all views created
SELECT table_schema, table_name
FROM information_schema.views
WHERE table_schema = 'gold'
ORDER BY table_name;

-- Verify row counts
SELECT 'fact_shipments' AS view_name, COUNT(*) AS row_count 
FROM gold.fact_shipments
UNION ALL
SELECT 'fact_orders', COUNT(*) 
FROM gold.fact_orders
UNION ALL
SELECT 'fact_logistics_performance', COUNT(*) 
FROM gold.fact_logistics_performance;