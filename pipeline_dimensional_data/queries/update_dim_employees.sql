USE ORDER_DDS;
GO

MERGE DimEmployees AS target
USING (
    SELECT
        EmployeeID,
        LastName,
        FirstName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        Notes,
        ReportsTo,
        PhotoPath,
        staging_raw_id_sk
    FROM Staging_Employees
) AS source
ON target.EmployeeID_NK = source.EmployeeID

WHEN MATCHED THEN
    UPDATE SET
        target.LastName = source.LastName,
        target.FirstName = source.FirstName,
        target.Title = source.Title,
        target.TitleOfCourtesy = source.TitleOfCourtesy,
        target.BirthDate = source.BirthDate,
        target.HireDate = source.HireDate,
        target.Address = source.Address,
        target.City = source.City,
        target.Region = source.Region,
        target.PostalCode = source.PostalCode,
        target.Country = source.Country,
        target.HomePhone = source.HomePhone,
        target.Extension = source.Extension,
        target.Notes = source.Notes,
        target.ReportsTo = source.ReportsTo,
        target.PhotoPath = source.PhotoPath,
        target.IsDeleted = 0,
        target.UpdatedDate = GETDATE()

WHEN NOT MATCHED THEN
    INSERT (
        EmployeeID_NK,
        LastName,
        FirstName,
        Title,
        TitleOfCourtesy,
        BirthDate,
        HireDate,
        Address,
        City,
        Region,
        PostalCode,
        Country,
        HomePhone,
        Extension,
        Notes,
        ReportsTo,
        PhotoPath,
        IsDeleted,
        SOR_SK,
        staging_raw_id_sk,
        CreatedDate,
        UpdatedDate
    )
    VALUES (
        source.EmployeeID,
        source.LastName,
        source.FirstName,
        source.Title,
        source.TitleOfCourtesy,
        source.BirthDate,
        source.HireDate,
        source.Address,
        source.City,
        source.Region,
        source.PostalCode,
        source.Country,
        source.HomePhone,
        source.Extension,
        source.Notes,
        source.ReportsTo,
        source.PhotoPath,
        0,
        (
            SELECT SOR_SK
            FROM Dim_SOR
            WHERE staging_table_name = 'Staging_Employees'
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
