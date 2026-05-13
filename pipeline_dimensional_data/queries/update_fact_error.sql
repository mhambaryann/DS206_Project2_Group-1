-- =============================================================================
-- update_fact_error.sql
-- Captures rows that failed to enter FactOrders due to missing or invalid
-- natural keys, inserting them into FactOrders_Error for audit purposes.
--
-- Parameters (passed at runtime by tasks.py):
--   {db_name}     : database name          (e.g. ORDER_DDS)
--   {schema_name} : schema                 (e.g. dbo)
--   {error_table} : error table name       (e.g. FactOrders_Error)
--   {start_date}  : period start           (YYYY-MM-DD)
--   {end_date}    : period end inclusive   (YYYY-MM-DD)
-- =============================================================================

-- ============================================================
-- STEP 1: Clear previous error rows for this period to keep
--         the error table in sync with each snapshot run.
-- ============================================================
DELETE FROM [{db_name}].[{schema_name}].[{error_table}]
WHERE ErrorDate >= '{start_date}'
  AND ErrorDate <  DATEADD(DAY, 1, CONVERT(DATE, '{end_date}'));

-- ============================================================
-- STEP 2: Insert rows where at least one dimension lookup
--         returned NULL (missing or invalid natural key).
--         Columns match exactly what FactOrders_Error defines:
--         OrderID_NK, CustomerID_NK, EmployeeID_NK,
--         ProductID_NK, ErrorReason, ErrorDate,
--         SOR_SK, staging_raw_id_sk
-- ============================================================
INSERT INTO [{db_name}].[{schema_name}].[{error_table}]
(
    OrderID_NK,
    CustomerID_NK,
    EmployeeID_NK,
    ProductID_NK,
    ErrorReason,
    ErrorDate,
    SOR_SK,
    staging_raw_id_sk
)
SELECT
    o.OrderID                            AS OrderID_NK,
    o.CustomerID                         AS CustomerID_NK,
    o.EmployeeID                         AS EmployeeID_NK,
    od.ProductID                         AS ProductID_NK,

    -- Build a readable description of exactly which key(s) failed
    CONCAT(
        CASE WHEN dc.Customer_SK  IS NULL
             THEN 'Missing CustomerID='  + ISNULL(CAST(o.CustomerID  AS NVARCHAR), 'NULL') + '; '
             ELSE '' END,
        CASE WHEN de.Employee_SK  IS NULL
             THEN 'Missing EmployeeID='  + ISNULL(CAST(o.EmployeeID  AS NVARCHAR), 'NULL') + '; '
             ELSE '' END,
        CASE WHEN dp.Product_SK   IS NULL
             THEN 'Missing ProductID='   + ISNULL(CAST(od.ProductID  AS NVARCHAR), 'NULL') + '; '
             ELSE '' END,
        CASE WHEN dsh.Shipper_SK  IS NULL
             THEN 'Missing ShipperID='   + ISNULL(CAST(o.ShipVia     AS NVARCHAR), 'NULL') + '; '
             ELSE '' END,
        CASE WHEN dt.Territory_SK IS NULL
             THEN 'Missing TerritoryID=' + ISNULL(CAST(o.TerritoryID AS NVARCHAR), 'NULL') + '; '
             ELSE '' END
    )                                    AS ErrorReason,

    o.OrderDate                          AS ErrorDate,

    sor.SOR_SK                           AS SOR_SK,
    o.staging_raw_id_sk                  AS staging_raw_id_sk

FROM [{db_name}].[{schema_name}].[Staging_Orders]       AS o
JOIN [{db_name}].[{schema_name}].[Staging_OrderDetails]  AS od
    ON od.OrderID = o.OrderID

-- Dim_SOR linkage
LEFT JOIN [{db_name}].[{schema_name}].[Dim_SOR]          AS sor
    ON sor.staging_table_name = 'Staging_Orders'

-- Same dimension lookups as update_fact.sql
LEFT JOIN [{db_name}].[{schema_name}].[DimCustomers]     AS dc
    ON dc.CustomerID_NK = o.CustomerID
   AND dc.IsCurrent = 1

LEFT JOIN [{db_name}].[{schema_name}].[DimEmployees]     AS de
    ON de.EmployeeID_NK = o.EmployeeID
   AND de.IsDeleted = 0

LEFT JOIN [{db_name}].[{schema_name}].[DimProducts]      AS dp
    ON dp.ProductID_NK = od.ProductID
   AND dp.IsCurrent = 1
   AND dp.IsDeleted = 0

LEFT JOIN [{db_name}].[{schema_name}].[DimShippers]      AS dsh
    ON dsh.ShipperID_NK = o.ShipVia

LEFT JOIN [{db_name}].[{schema_name}].[DimTerritories]   AS dt
    ON dt.TerritoryID_NK = o.TerritoryID

-- Period filter
WHERE o.OrderDate >= '{start_date}'
  AND o.OrderDate <  DATEADD(DAY, 1, CONVERT(DATE, '{end_date}'))

-- Only rows where at least one dimension lookup failed
  AND (
        dc.Customer_SK  IS NULL
     OR de.Employee_SK  IS NULL
     OR dp.Product_SK   IS NULL
     OR dsh.Shipper_SK  IS NULL
     OR dt.Territory_SK IS NULL
  );
