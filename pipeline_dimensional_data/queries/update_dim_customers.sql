USE ORDER_DDS;
GO

UPDATE target
SET
    target.EndDate = GETDATE(),
    target.IsCurrent = 0,
    target.UpdatedDate = GETDATE()
FROM DimCustomers target
INNER JOIN Staging_Customers source
    ON target.CustomerID_NK = source.CustomerID
WHERE target.IsCurrent = 1
AND (
       ISNULL(target.CompanyName, '') <> ISNULL(source.CompanyName, '')
    OR ISNULL(target.ContactName, '') <> ISNULL(source.ContactName, '')
    OR ISNULL(target.ContactTitle, '') <> ISNULL(source.ContactTitle, '')
    OR ISNULL(target.Address, '') <> ISNULL(source.Address, '')
    OR ISNULL(target.City, '') <> ISNULL(source.City, '')
    OR ISNULL(target.Region, '') <> ISNULL(source.Region, '')
    OR ISNULL(target.PostalCode, '') <> ISNULL(source.PostalCode, '')
    OR ISNULL(target.Country, '') <> ISNULL(source.Country, '')
    OR ISNULL(target.Phone, '') <> ISNULL(source.Phone, '')
    OR ISNULL(target.Fax, '') <> ISNULL(source.Fax, '')
);

INSERT INTO DimCustomers (
    CustomerID_NK,
    CompanyName,
    ContactName,
    ContactTitle,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    StartDate,
    EndDate,
    IsCurrent,
    SOR_SK,
    staging_raw_id_sk,
    CreatedDate,
    UpdatedDate
)
SELECT
    source.CustomerID,
    source.CompanyName,
    source.ContactName,
    source.ContactTitle,
    source.Address,
    source.City,
    source.Region,
    source.PostalCode,
    source.Country,
    source.Phone,
    source.Fax,
    GETDATE(),
    NULL,
    1,
    (
        SELECT SOR_SK
        FROM Dim_SOR
        WHERE staging_table_name = 'Staging_Customers'
    ),
    source.staging_raw_id_sk,
    GETDATE(),
    GETDATE()
FROM Staging_Customers source
LEFT JOIN DimCustomers target
    ON source.CustomerID = target.CustomerID_NK
    AND target.IsCurrent = 1
WHERE target.Customer_SK IS NULL
OR (
       ISNULL(target.CompanyName, '') <> ISNULL(source.CompanyName, '')
    OR ISNULL(target.ContactName, '') <> ISNULL(source.ContactName, '')
    OR ISNULL(target.ContactTitle, '') <> ISNULL(source.ContactTitle, '')
    OR ISNULL(target.Address, '') <> ISNULL(source.Address, '')
    OR ISNULL(target.City, '') <> ISNULL(source.City, '')
    OR ISNULL(target.Region, '') <> ISNULL(source.Region, '')
    OR ISNULL(target.PostalCode, '') <> ISNULL(source.PostalCode, '')
    OR ISNULL(target.Country, '') <> ISNULL(source.Country, '')
    OR ISNULL(target.Phone, '') <> ISNULL(source.Phone, '')
    OR ISNULL(target.Fax, '') <> ISNULL(source.Fax, '')
);
GO
