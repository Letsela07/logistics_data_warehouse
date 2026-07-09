ALTER PROCEDURE dbo.usp_load_silver
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;
    DECLARE @row_count_before INT;
    DECLARE @row_count_after INT;

    -- =============================================
    -- Step 1: Load Silver Customer
    -- =============================================
    BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @row_count_before = COUNT(*) FROM silver.customer;

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

        SELECT @row_count_after = COUNT(*) FROM silver.customer;
        SET @end_time = GETDATE();

        INSERT INTO dbo.pipeline_log (
            procedure_name, step_name, source_layer,
            source_table, target_table, start_time, end_time,
            row_count_before, row_count_after, expected_row_count,
            status
        )
        VALUES (
            'usp_load_silver', 'Load Silver Customer', 'Silver',
            'bronze.customer', 'silver.customer', @start_time, @end_time,
            @row_count_before, @row_count_after, 750,
            'SUCCESS'
        );

    END TRY
    BEGIN CATCH
        INSERT INTO dbo.pipeline_log (
            procedure_name, step_name, source_layer,
            source_table, target_table, start_time, end_time,
            status, error_message
        )
        VALUES (
            'usp_load_silver', 'Load Silver Customer', 'Silver',
            'bronze.customer', 'silver.customer', @start_time, GETDATE(),
            'FAILED', ERROR_MESSAGE()
        );
    END CATCH


    -- =============================================
    -- Step 2: Load Silver Shipment
    -- =============================================
    BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @row_count_before = COUNT(*) FROM silver.shipment;

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
                WHEN ISNUMERIC(d_country) = 1 
                    THEN 'Singapore'
                ELSE TRIM(d_country)
            END AS destination_country,
            CASE 
                WHEN ISNUMERIC(d_country) = 1 
                    THEN CAST(d_country AS INT)
                ELSE CAST(value AS INT)
            END AS shipment_value,
            CASE 
                WHEN ISNUMERIC(d_country) = 1 
                    THEN CAST(value AS DECIMAL(10,2))
                ELSE CAST(freight_cost AS DECIMAL(10,2))
            END AS freight_cost,
            CASE 
                WHEN ISNUMERIC(d_country) = 1 
                    THEN CAST(freight_cost AS DECIMAL(10,2))
                ELSE
                    CASE
                        WHEN ISNUMERIC(customs_clearance_time_days) = 1
                            THEN CAST(customs_clearance_time_days AS DECIMAL(10,2))
                        ELSE NULL
                    END
            END AS customs_clearance_days,
            CASE 
                WHEN ISNUMERIC(d_country) = 1 
                    THEN LTRIM(RTRIM(
                        LEFT(customs_clearance_time_days,
                            CHARINDEX(CHAR(13), customs_clearance_time_days + CHAR(13)) - 1)
                        ))
                ELSE
                    LTRIM(RTRIM(
                        LEFT(delivery_status,
                            CHARINDEX(CHAR(13), delivery_status + CHAR(13)) - 1)
                        ))
            END AS delivery_status
        FROM bronze.shipment;

        SELECT @row_count_after = COUNT(*) FROM silver.shipment;
        SET @end_time = GETDATE();

        INSERT INTO dbo.pipeline_log (
            procedure_name, step_name, source_layer,
            source_table, target_table, start_time, end_time,
            row_count_before, row_count_after, expected_row_count,
            status
        )
        VALUES (
            'usp_load_silver', 'Load Silver Shipment', 'Silver',
            'bronze.shipment', 'silver.shipment', @start_time, @end_time,
            @row_count_before, @row_count_after, 704,
            'SUCCESS'
        );

    END TRY
    BEGIN CATCH
        INSERT INTO dbo.pipeline_log (
            procedure_name, step_name, source_layer,
            source_table, target_table, start_time, end_time,
            status, error_message
        )
        VALUES (
            'usp_load_silver', 'Load Silver Shipment', 'Silver',
            'bronze.shipment', 'silver.shipment', @start_time, GETDATE(),
            'FAILED', ERROR_MESSAGE()
        );
    END CATCH


    -- =============================================
    -- Step 3: Load Silver Logistics Performance
    -- =============================================
    BEGIN TRY
        SET @start_time = GETDATE();
        SELECT @row_count_before = COUNT(*) FROM silver.logistics_performance;

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

        SELECT @row_count_after = COUNT(*) FROM silver.logistics_performance;
        SET @end_time = GETDATE();

        INSERT INTO dbo.pipeline_log (
            procedure_name, step_name, source_layer,
            source_table, target_table, start_time, end_time,
            row_count_before, row_count_after, expected_row_count,
            status
        )
        VALUES (
            'usp_load_silver', 'Load Silver Logistics Performance', 'Silver',
            'bronze.logistics_performance', 'silver.logistics_performance', 
            @start_time, @end_time,
            @row_count_before, @row_count_after, 100,
            'SUCCESS'
        );

    END TRY
    BEGIN CATCH
        INSERT INTO dbo.pipeline_log (
            procedure_name, step_name, source_layer,
            source_table, target_table, start_time, end_time,
            status, error_message
        )
        VALUES (
            'usp_load_silver', 'Load Silver Logistics Performance', 'Silver',
            'bronze.logistics_performance', 'silver.logistics_performance',
            @start_time, GETDATE(),
            'FAILED', ERROR_MESSAGE()
        );
    END CATCH

END;