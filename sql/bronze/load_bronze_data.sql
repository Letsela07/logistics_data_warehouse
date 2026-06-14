-- =============================================
-- LOGISTICS DATA WAREHOUSE PROJECT
-- Bronze Layer: Load Raw Data
-- =============================================
-- Purpose: Load raw CSV data into bronze tables
-- FIRSTROW = 2 skips the header row
-- FIELDTERMINATOR = ',' for CSV format
-- ROWTERMINATOR = '\n' for new lines
-- TABLOCK for better load performance
-- =============================================


-- =============================================
-- Step 1: Load Customer Data
-- =============================================

BULK INSERT bronze.customer
FROM 'C:/Mydata/to/customer.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Verify Customer Load
SELECT COUNT(*) AS customer_count 
FROM bronze.customer;

-- Preview Customer Data
SELECT TOP 5 * 
FROM bronze.customer;


-- =============================================
-- Step 2: Load Shipment Data
-- =============================================

BULK INSERT bronze.shipment
FROM 'C:/Mydata/to/shipment.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Verify Shipment Load
SELECT COUNT(*) AS shipment_count 
FROM bronze.shipment;

-- Preview Shipment Data
SELECT TOP 5 * 
FROM bronze.shipment;


-- =============================================
-- Step 3: Load Logistics Performance Data
-- =============================================

BULK INSERT bronze.logistics_performance
FROM 'C:/Mydata/to/logistics_performance.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Verify Logistics Performance Load
SELECT COUNT(*) AS logistics_count 
FROM bronze.logistics_performance;

-- Preview Logistics Performance Data
SELECT TOP 5 * 
FROM bronze.logistics_performance;


-- =============================================
-- Step 4: Final Verification
-- All 3 tables loaded successfully
-- =============================================

SELECT 
    'bronze.customer' AS table_name,
    COUNT(*) AS row_count 
FROM bronze.customer
UNION ALL
SELECT 
    'bronze.shipment',
    COUNT(*) 
FROM bronze.shipment
UNION ALL
SELECT 
    'bronze.logistics_performance',
    COUNT(*) 
FROM bronze.logistics_performance;