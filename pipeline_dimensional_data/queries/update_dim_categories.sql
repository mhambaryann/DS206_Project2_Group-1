USE ORDER_DDS;
GO

MERGE DimCategories AS target
USING (
    SELECT
        CategoryID,
        CategoryName,
        Description,
        staging_raw_id_sk
    FROM Staging_Categories
) AS source
ON target.CategoryID_NK = source.CategoryID

WHEN MATCHED THEN
    UPDATE SET
        target.CategoryName = source.CategoryName,
        target.Description = source.Description,
        target.IsDeleted = 0,
        target.UpdatedDate = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (
        CategoryID_NK,
        CategoryName,
        Description,
        IsDeleted,
        SOR_SK,
        staging_raw_id_sk,
        CreatedDate,
        UpdatedDate
    )
    VALUES (
        source.CategoryID,
        source.CategoryName,
        source.Description,
        0,
        (
            SELECT SOR_SK
            FROM Dim_SOR
            WHERE staging_table_name = 'Staging_Categories'
        ),
        source.staging_raw_id_sk,
        GETDATE(),
        GETDATE()
    )

WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET
        target.IsDeleted = 1,
        target.UpdatedDate = GETDATE();
GO
