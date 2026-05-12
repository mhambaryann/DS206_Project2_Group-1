USE ORDER_DDS;
GO

MERGE DimShippers AS target
USING (
    SELECT
        ShipperID,
        CompanyName,
        Phone,
        staging_raw_id_sk
    FROM Staging_Shippers
) AS source
ON target.ShipperID_NK = source.ShipperID

WHEN MATCHED THEN
    UPDATE SET
        target.CompanyName = source.CompanyName,
        target.Phone = source.Phone,
        target.UpdatedDate = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (
        ShipperID_NK,
        CompanyName,
        Phone,
        SOR_SK,
        staging_raw_id_sk,
        CreatedDate,
        UpdatedDate
    )
    VALUES (
        source.ShipperID,
        source.CompanyName,
        source.Phone,
        (
            SELECT SOR_SK
            FROM Dim_SOR
            WHERE staging_table_name = 'Staging_Shippers'
        ),
        source.staging_raw_id_sk,
        GETDATE(),
        GETDATE()
    );
GO
