USE ORDER_DDS;
GO

MERGE DimRegion AS target
USING (
    SELECT
        RegionID,
        RegionDescription,
        RegionCategory,
        RegionImportance,
        staging_raw_id_sk
    FROM Staging_Region
) AS source
ON target.RegionID_NK = source.RegionID

WHEN MATCHED THEN
    UPDATE SET
        target.RegionDescription = source.RegionDescription,
        target.RegionCategory = source.RegionCategory,
        target.RegionImportance = source.RegionImportance,
        target.UpdatedDate = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (
        RegionID_NK,
        RegionDescription,
        RegionCategory,
        RegionImportance,
        SOR_SK,
        staging_raw_id_sk,
        CreatedDate,
        UpdatedDate
    )
    VALUES (
        source.RegionID,
        source.RegionDescription,
        source.RegionCategory,
        source.RegionImportance,
        (
            SELECT SOR_SK
            FROM Dim_SOR
            WHERE staging_table_name = 'Staging_Region'
        ),
        source.staging_raw_id_sk,
        GETDATE(),
        GETDATE()
    );
GO
