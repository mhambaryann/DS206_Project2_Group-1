USE ORDER_DDS;
GO

MERGE DimTerritories AS target
USING (
    SELECT
        TerritoryID,
        TerritoryDescription,
        TerritoryCode,
        RegionID,
        staging_raw_id_sk
    FROM Staging_Territories
) AS source
ON target.TerritoryID_NK = source.TerritoryID

WHEN MATCHED
AND ISNULL(target.TerritoryDescription_Current, '') 
    <> ISNULL(source.TerritoryDescription, '')
THEN
    UPDATE SET
        target.TerritoryDescription_Prior =
            target.TerritoryDescription_Current,

        target.TerritoryDescription_Current =
            source.TerritoryDescription,

        target.TerritoryCode =
            source.TerritoryCode,

        target.RegionID_NK =
            source.RegionID,

        target.UpdatedDate = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (
        TerritoryID_NK,
        TerritoryDescription_Current,
        TerritoryDescription_Prior,
        TerritoryCode,
        RegionID_NK,
        SOR_SK,
        staging_raw_id_sk,
        CreatedDate,
        UpdatedDate
    )
    VALUES (
        source.TerritoryID,
        source.TerritoryDescription,
        NULL,
        source.TerritoryCode,
        source.RegionID,
        (
            SELECT SOR_SK
            FROM Dim_SOR
            WHERE staging_table_name = 'Staging_Territories'
        ),
        source.staging_raw_id_sk,
        GETDATE(),
        GETDATE()
    );
GO
