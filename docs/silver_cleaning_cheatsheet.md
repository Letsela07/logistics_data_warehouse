=============================================
DATA CLEANING CHEAT SHEET
Silver Layer — Standard Checks
=============================================

STEP 1: COMPLETENESS CHECK
Are there missing values?
---------------------------------------------
-- Check NULLs
SELECT 
    SUM(CASE WHEN column IS NULL THEN 1 ELSE 0 END) AS null_count
FROM table;

-- Check empty strings
SELECT COUNT(*) 
FROM table 
WHERE column = '';

-- Check both together
SELECT COUNT(*)
FROM table
WHERE column IS NULL OR TRIM(column) = '';

✅ Expected result: 0 nulls and 0 empty strings
⚠️ If found: Use ISNULL() or NULLIF() to handle


STEP 2: UNIQUENESS CHECK
Are there duplicate rows?
---------------------------------------------
-- Simple duplicate check
SELECT column, COUNT(*) AS count
FROM table
GROUP BY column
HAVING COUNT(*) > 1;

-- Full row duplicate check
SELECT *, COUNT(*) AS count
FROM table
GROUP BY ALL columns
HAVING COUNT(*) > 1;

✅ Expected result: No results returned
⚠️ If found: Use SELECT DISTINCT or ROW_NUMBER()


STEP 3: CONSISTENCY CHECK
Is the data stored the same way?
---------------------------------------------
-- Check distinct values in categorical columns
SELECT DISTINCT column
FROM table
ORDER BY column;

-- Check for leading/trailing spaces
SELECT column,
    LEN(column) AS original_length,
    LEN(TRIM(column)) AS trimmed_length
FROM table
WHERE LEN(column) != LEN(TRIM(column));

-- Check for mixed case
SELECT DISTINCT UPPER(column), column
FROM table;

✅ Expected result: Clean consistent values
⚠️ If found: Use TRIM(), UPPER(), LOWER()


STEP 4: VALIDITY CHECK
Does the data make sense?
---------------------------------------------
-- Check numeric ranges
SELECT 
    MIN(CAST(column AS FLOAT)) AS min_value,
    MAX(CAST(column AS FLOAT)) AS max_value,
    AVG(CAST(column AS FLOAT)) AS avg_value
FROM table;

-- Check dates are valid
SELECT column
FROM table
WHERE TRY_CAST(column AS DATE) IS NULL;

-- Check numeric columns have no text
SELECT column
FROM table
WHERE ISNUMERIC(column) = 0;

✅ Expected result: Values within expected range
⚠️ If found: Use CASE WHEN to handle outliers


STEP 5: ACCURACY CHECK
Does the data reflect reality?
---------------------------------------------
-- Check date ranges make sense
SELECT 
    MIN(CAST(date_column AS DATE)) AS earliest,
    MAX(CAST(date_column AS DATE)) AS latest
FROM table;

-- Cross column validation
-- Example: ship date should be after order date
SELECT *
FROM table
WHERE CAST(ship_date AS DATE) < CAST(order_date AS DATE);

✅ Expected result: Logical date sequences
⚠️ If found: Document and flag for business review


STEP 6: ROW COUNT VALIDATION
Did we lose or gain rows?
---------------------------------------------
-- Always compare Bronze vs Silver counts!
SELECT 
    'bronze' AS layer, COUNT(*) AS rows 
FROM bronze.table
UNION ALL
SELECT 
    'silver' AS layer, COUNT(*) AS rows 
FROM silver.table;

✅ Expected result: Same count in both layers
⚠️ If different: Investigate why rows were lost


=============================================
QUICK REFERENCE — CLEANING FUNCTIONS
=============================================

TRIM(column)          → Remove spaces
UPPER(column)         → Convert to uppercase
LOWER(column)         → Convert to lowercase
ISNULL(column, 'X')  → Replace NULL with X
NULLIF(column, '')    → Convert empty to NULL
ISNUMERIC(column)     → Check if numeric (1/0)
TRY_CAST(col AS type) → Safe type conversion
CAST(col AS type)     → Convert data type

CASE WHEN condition THEN value
     WHEN condition THEN value
     ELSE value
END                   → Conditional logic

ROW_NUMBER() OVER (
    PARTITION BY column
    ORDER BY column
)                     → Number duplicate rows


=============================================
DATA TYPE CONVERSIONS
=============================================

VARCHAR → DATE
CAST(column AS DATE)
TRY_CAST(column AS DATE) ← safer option

VARCHAR → INT
CAST(column AS INT)

VARCHAR → DECIMAL
CAST(column AS DECIMAL(10,2))

VARCHAR → FLOAT
CAST(column AS FLOAT)

VARCHAR → BIGINT
CAST(column AS BIGINT)


=============================================
SILVER LAYER RULES
=============================================

✅ Always TRIM text columns
✅ Always convert dates to DATE type
✅ Always convert numbers to proper types
✅ Always handle NULLs explicitly
✅ Always remove duplicates with DISTINCT
✅ Always validate row counts after loading
✅ Always document issues found
✅ Never delete data — set to NULL instead
✅ Never change business logic in Silver
✅ Silver cleans — Gold transforms!


=============================================
CHECKLIST BEFORE MOVING TO GOLD
=============================================

□ Step 1: Completeness check done
□ Step 2: Uniqueness check done  
□ Step 3: Consistency check done
□ Step 4: Validity check done
□ Step 5: Accuracy check done
□ Step 6: Row counts match Bronze
□ All issues documented in Notion
□ Silver tables created with proper data types
□ Data loaded into Silver tables
□ SELECT TOP 10 preview looks clean
□ Ready for Gold layer!
=============================================