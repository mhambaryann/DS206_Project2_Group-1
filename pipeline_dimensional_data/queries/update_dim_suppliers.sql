USE ORDER_DDS;
GO

INSERT INTO DimSuppliers_History (
    SupplierID_NK,
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
    HomePage,
    VersionStartDate,
    VersionEndDate,
    SOR_SK,
    staging_raw_id_sk
)
SELECT
    target.SupplierID_NK,
    target.CompanyName,
    target.ContactName,
    target.ContactTitle,
    target.Address,
    target.City,
    target.Region,
    target.PostalCode,
    target.Country,
    target.Phone,
    target.Fax,
    target.HomePage,
    target.CreatedDate,
    GETDATE(),
    target.SOR_SK,
    target.staging_raw_id_sk
FROM DimSuppliers target
INNER JOIN Staging_Suppliers source
    ON target.SupplierID_NK = source.SupplierID
WHERE
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
    OR ISNULL(target.HomePage, '') <> ISNULL(source.HomePage, '');

MERGE DimSuppliers AS target
USING (
    SELECT
        SupplierID,
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
        HomePage,
        staging_raw_id_sk
    FROM Staging_Suppliers
) AS source
ON target.SupplierID_NK = source.SupplierID

WHEN MATCHED THEN
    UPDATE SET
        target.CompanyName = source.CompanyName,
        target.ContactName = source.ContactName,
        target.ContactTitle = source.ContactTitle,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country = source.Country,
        target.Phone = source.Phone,
        target.Fax = source.Fax,
        target.HomePage = source.HomePage,
        target.UpdatedDate = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (
        SupplierID_NK,
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
        HomePage,
        SOR_SK,
        staging_raw_id_sk,
        CreatedDate,
        UpdatedDate
    )
    VALUES (
        source.SupplierID,
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
        source.HomePage,
        (
            SELECT SOR_SK
            FROM Dim_SOR
            WHERE staging_table_name = 'Staging_Suppliers'
        ),
        source.staging_raw_id_sk,
        GETDATE(),
        GETDATE()
    );
GO
