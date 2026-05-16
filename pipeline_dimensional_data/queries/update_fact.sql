-- =============================================================================
-- update_fact.sql
-- SNAPSHOT-based ingestion into FactOrders.
-- All staging tables live in the same database as the dimensional tables.
--
-- Parameters (passed at runtime by tasks.py):
--   {db_name}     : database name          (e.g. ORDER_DDS)
--   {schema_name} : schema                 (e.g. dbo)
--   {fact_table}  : fact table name        (e.g. FactOrders)
--   {start_date}  : period start           (YYYY-MM-DD)
--   {end_date}    : period end inclusive   (YYYY-MM-DD)
--
-- QA decision applied:
--   Invalid rows are not inserted into FactOrders. A row enters the fact table
--   only when every required dimension lookup resolves to a valid surrogate key.
--   Failed rows are captured separately by update_fact_error.sql.
-- =============================================================================

-- ============================================================
-- STEP 1: Delete existing snapshot rows for the period.
--         This is the SNAPSHOT pattern: wipe and re-insert
--         so every run produces a clean, reproducible result.
-- ============================================================
DELETE FROM [{db_name}].[{schema_name}].[{fact_table}]
WHERE OrderDate >= '{start_date}'
  AND OrderDate <  DATEADD(DAY, 1, CONVERT(DATE, '{end_date}'));

-- ============================================================
-- STEP 2: Insert a fresh snapshot for the period.
--         Join Staging_Orders + Staging_OrderDetails, resolve
--         all dimension surrogate keys, link to Dim_SOR.
--
--         The WHERE clause keeps the fact table referentially clean:
--         if any required dimension lookup is missing, the row is
--         excluded here and handled by update_fact_error.sql.
-- ============================================================
INSERT INTO [{db_name}].[{schema_name}].[{fact_table}]
(
    OrderID_NK,
    Customer_SK,
    Employee_SK,
    Product_SK,
    Category_SK,
    Supplier_SK,
    Shipper_SK,
    Territory_SK,
    Region_SK,
    OrderDate,
    RequiredDate,
    ShippedDate,
    UnitPrice,
    Quantity,
    Discount,
    Freight,
    SOR_SK,
    staging_raw_id_sk
)
SELECT
    o.OrderID                            AS OrderID_NK,

    -- Customer (SCD2: active row only)
    dc.Customer_SK                       AS Customer_SK,

    -- Employee (SCD1 with delete: single active row per NK)
    de.Employee_SK                       AS Employee_SK,

    -- Product (SCD2 with delete-closing: active row only)
    dp.Product_SK                        AS Product_SK,

    -- Category (SCD1 with delete: resolved through Product)
    dcat.Category_SK                     AS Category_SK,

    -- Supplier (SCD4: resolved through Product, current row)
    dsup.Supplier_SK                     AS Supplier_SK,

    -- Shipper (SCD1: ShipVia is the natural key)
    dsh.Shipper_SK                       AS Shipper_SK,

    -- Territory (SCD3: single row per NK)
    dt.Territory_SK                      AS Territory_SK,

    -- Region (SCD1: resolved through Territory)
    dr.Region_SK                         AS Region_SK,

    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,

    od.UnitPrice,
    od.Quantity,
    od.Discount,
    o.Freight,

    -- SOR linkage: tie each fact row to its staging source
    sor.SOR_SK                           AS SOR_SK,
    o.staging_raw_id_sk                  AS staging_raw_id_sk

FROM [{db_name}].[{schema_name}].[Staging_Orders]       AS o
JOIN [{db_name}].[{schema_name}].[Staging_OrderDetails] AS od
    ON od.OrderID = o.OrderID

-- Dim_SOR: look up the SOR_SK for the Staging_Orders table
LEFT JOIN [{db_name}].[{schema_name}].[Dim_SOR]          AS sor
    ON sor.staging_table_name = 'Staging_Orders'

-- Customer (SCD2: only the current active row)
LEFT JOIN [{db_name}].[{schema_name}].[DimCustomers]     AS dc
    ON dc.CustomerID_NK = o.CustomerID
   AND dc.IsCurrent = 1

-- Employee (SCD1 with delete: only non-deleted row)
LEFT JOIN [{db_name}].[{schema_name}].[DimEmployees]     AS de
    ON de.EmployeeID_NK = o.EmployeeID
   AND de.IsDeleted = 0

-- Product (SCD2 with delete-closing: current and non-deleted)
LEFT JOIN [{db_name}].[{schema_name}].[DimProducts]      AS dp
    ON dp.ProductID_NK = od.ProductID
   AND dp.IsCurrent = 1
   AND dp.IsDeleted = 0

-- Category through Product (SCD1 with delete)
LEFT JOIN [{db_name}].[{schema_name}].[DimCategories]    AS dcat
    ON dcat.CategoryID_NK = dp.CategoryID_NK
   AND dcat.IsDeleted = 0

-- Supplier through Product (SCD4: current row in main table)
LEFT JOIN [{db_name}].[{schema_name}].[DimSuppliers]     AS dsup
    ON dsup.SupplierID_NK = dp.SupplierID_NK

-- Shipper (SCD1)
LEFT JOIN [{db_name}].[{schema_name}].[DimShippers]      AS dsh
    ON dsh.ShipperID_NK = o.ShipVia

-- Territory (SCD3: one row per NK)
LEFT JOIN [{db_name}].[{schema_name}].[DimTerritories]   AS dt
    ON dt.TerritoryID_NK = o.TerritoryID

-- Region through Territory (SCD1)
LEFT JOIN [{db_name}].[{schema_name}].[DimRegion]        AS dr
    ON dr.RegionID_NK = dt.RegionID_NK

-- Period filter applied to OrderDate in staging.
-- Required dimension checks implement the project rule that rows with
-- missing/invalid natural keys should not enter FactOrders.
WHERE o.OrderDate >= '{start_date}'
  AND o.OrderDate <  DATEADD(DAY, 1, CONVERT(DATE, '{end_date}'))
  AND dc.Customer_SK  IS NOT NULL
  AND de.Employee_SK  IS NOT NULL
  AND dp.Product_SK   IS NOT NULL
  AND dcat.Category_SK IS NOT NULL
  AND dsup.Supplier_SK IS NOT NULL
  AND dsh.Shipper_SK  IS NOT NULL
  AND dt.Territory_SK IS NOT NULL
  AND dr.Region_SK    IS NOT NULL;