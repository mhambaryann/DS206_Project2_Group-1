USE ORDER_DDS;
GO

UPDATE target
SET
    target.EndDate = GETDATE(),
    target.IsCurrent = 0,
    target.UpdatedDate = GETDATE()
FROM DimProducts target
INNER JOIN Staging_Products source
    ON target.ProductID_NK = source.ProductID
WHERE target.IsCurrent = 1
AND (
       ISNULL(target.ProductName, '') <> ISNULL(source.ProductName, '')
    OR ISNULL(target.SupplierID_NK, -1) <> ISNULL(source.SupplierID, -1)
    OR ISNULL(target.CategoryID_NK, -1) <> ISNULL(source.CategoryID, -1)
    OR ISNULL(target.QuantityPerUnit, '') <> ISNULL(source.QuantityPerUnit, '')
    OR ISNULL(target.UnitPrice, -1) <> ISNULL(source.UnitPrice, -1)
    OR ISNULL(target.UnitsInStock, -1) <> ISNULL(source.UnitsInStock, -1)
    OR ISNULL(target.UnitsOnOrder, -1) <> ISNULL(source.UnitsOnOrder, -1)
    OR ISNULL(target.ReorderLevel, -1) <> ISNULL(source.ReorderLevel, -1)
    OR ISNULL(target.Discontinued, -1) <> ISNULL(source.Discontinued, -1)
);

INSERT INTO DimProducts (
    ProductID_NK,
    ProductName,
    SupplierID_NK,
    CategoryID_NK,
    QuantityPerUnit,
    UnitPrice,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued,
    StartDate,
    EndDate,
    IsCurrent,
    IsDeleted,
    SOR_SK,
    staging_raw_id_sk,
    CreatedDate,
    UpdatedDate
)
SELECT
    source.ProductID,
    source.ProductName,
    source.SupplierID,
    source.CategoryID,
    source.QuantityPerUnit,
    source.UnitPrice,
    source.UnitsInStock,
    source.UnitsOnOrder,
    source.ReorderLevel,
    source.Discontinued,
    GETDATE(),
    NULL,
    1,
    0,
    (
        SELECT SOR_SK
        FROM Dim_SOR
        WHERE staging_table_name = 'Staging_Products'
    ),
    source.staging_raw_id_sk,
    GETDATE(),
    GETDATE()
FROM Staging_Products source
LEFT JOIN DimProducts target
    ON source.ProductID = target.ProductID_NK
    AND target.IsCurrent = 1
WHERE target.Product_SK IS NULL
OR (
       ISNULL(target.ProductName, '') <> ISNULL(source.ProductName, '')
    OR ISNULL(target.SupplierID_NK, -1) <> ISNULL(source.SupplierID, -1)
    OR ISNULL(target.CategoryID_NK, -1) <> ISNULL(source.CategoryID, -1)
    OR ISNULL(target.QuantityPerUnit, '') <> ISNULL(source.QuantityPerUnit, '')
    OR ISNULL(target.UnitPrice, -1) <> ISNULL(source.UnitPrice, -1)
    OR ISNULL(target.UnitsInStock, -1) <> ISNULL(source.UnitsInStock, -1)
    OR ISNULL(target.UnitsOnOrder, -1) <> ISNULL(source.UnitsOnOrder, -1)
    OR ISNULL(target.ReorderLevel, -1) <> ISNULL(source.ReorderLevel, -1)
    OR ISNULL(target.Discontinued, -1) <> ISNULL(source.Discontinued, -1)
);

UPDATE target
SET
    target.IsDeleted = 1,
    target.IsCurrent = 0,
    target.EndDate = GETDATE(),
    target.UpdatedDate = GETDATE()
FROM DimProducts target
LEFT JOIN Staging_Products source
    ON target.ProductID_NK = source.ProductID
WHERE source.ProductID IS NULL
AND target.IsCurrent = 1;
GO
