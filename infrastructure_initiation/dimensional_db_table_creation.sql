USE ORDER_DDS;
GO

DROP TABLE IF EXISTS FactOrders_Error;
DROP TABLE IF EXISTS FactOrders;
DROP TABLE IF EXISTS DimSuppliers_History;
DROP TABLE IF EXISTS DimTerritories;
DROP TABLE IF EXISTS DimSuppliers;
DROP TABLE IF EXISTS DimShippers;
DROP TABLE IF EXISTS DimRegion;
DROP TABLE IF EXISTS DimProducts;
DROP TABLE IF EXISTS DimEmployees;
DROP TABLE IF EXISTS DimCustomers;
DROP TABLE IF EXISTS DimCategories;
DROP TABLE IF EXISTS Dim_SOR;
GO

CREATE TABLE Dim_SOR (
    SOR_SK INT IDENTITY(1,1) PRIMARY KEY,
    staging_table_name NVARCHAR(255) NOT NULL UNIQUE
);
GO

INSERT INTO Dim_SOR (staging_table_name)
VALUES
('Staging_Categories'),
('Staging_Customers'),
('Staging_Employees'),
('Staging_OrderDetails'),
('Staging_Orders'),
('Staging_Products'),
('Staging_Region'),
('Staging_Shippers'),
('Staging_Suppliers'),
('Staging_Territories');
GO

CREATE TABLE DimCategories (
    Category_SK INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID_NK INT NOT NULL,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX),
    IsDeleted BIT DEFAULT 0,
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimCustomers (
    Customer_SK INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID_NK CHAR(5) NOT NULL,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    StartDate DATETIME NOT NULL DEFAULT GETDATE(),
    EndDate DATETIME NULL,
    IsCurrent BIT DEFAULT 1,
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimEmployees (
    Employee_SK INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID_NK INT NOT NULL,
    LastName NVARCHAR(255),
    FirstName NVARCHAR(255),
    Title NVARCHAR(255),
    TitleOfCourtesy NVARCHAR(50),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    HomePhone NVARCHAR(50),
    Extension NVARCHAR(10),
    Notes NVARCHAR(MAX),
    ReportsTo INT,
    PhotoPath NVARCHAR(255),
    IsDeleted BIT DEFAULT 0,
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimProducts (
    Product_SK INT IDENTITY(1,1) PRIMARY KEY,
    ProductID_NK INT NOT NULL,
    ProductName NVARCHAR(255),
    SupplierID_NK INT,
    CategoryID_NK INT,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(18,2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT,
    StartDate DATETIME NOT NULL DEFAULT GETDATE(),
    EndDate DATETIME NULL,
    IsCurrent BIT DEFAULT 1,
    IsDeleted BIT DEFAULT 0,
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimRegion (
    Region_SK INT IDENTITY(1,1) PRIMARY KEY,
    RegionID_NK INT NOT NULL,
    RegionDescription NVARCHAR(255),
    RegionCategory NVARCHAR(255),
    RegionImportance NVARCHAR(255),
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimShippers (
    Shipper_SK INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID_NK INT NOT NULL,
    CompanyName NVARCHAR(255),
    Phone NVARCHAR(50),
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimSuppliers (
    Supplier_SK INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID_NK INT NOT NULL,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(MAX),
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimSuppliers_History (
    SupplierHistory_SK INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID_NK INT NOT NULL,
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50),
    HomePage NVARCHAR(MAX),
    VersionStartDate DATETIME,
    VersionEndDate DATETIME,
    SOR_SK INT,
    staging_raw_id_sk INT,
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE DimTerritories (
    Territory_SK INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID_NK NVARCHAR(50) NOT NULL,
    TerritoryDescription_Current NVARCHAR(255),
    TerritoryDescription_Prior NVARCHAR(255),
    TerritoryCode NVARCHAR(50),
    RegionID_NK INT,
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE FactOrders (
    FactOrder_SK INT IDENTITY(1,1) PRIMARY KEY,
    OrderID_NK INT NOT NULL,
    Customer_SK INT,
    Employee_SK INT,
    Product_SK INT,
    Category_SK INT,
    Supplier_SK INT,
    Shipper_SK INT,
    Territory_SK INT,
    Region_SK INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    UnitPrice DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Freight DECIMAL(18,2),
    SnapshotDate DATETIME DEFAULT GETDATE(),
    SOR_SK INT,
    staging_raw_id_sk INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (Customer_SK) REFERENCES DimCustomers(Customer_SK),
    FOREIGN KEY (Employee_SK) REFERENCES DimEmployees(Employee_SK),
    FOREIGN KEY (Product_SK) REFERENCES DimProducts(Product_SK),
    FOREIGN KEY (Category_SK) REFERENCES DimCategories(Category_SK),
    FOREIGN KEY (Supplier_SK) REFERENCES DimSuppliers(Supplier_SK),
    FOREIGN KEY (Shipper_SK) REFERENCES DimShippers(Shipper_SK),
    FOREIGN KEY (Territory_SK) REFERENCES DimTerritories(Territory_SK),
    FOREIGN KEY (Region_SK) REFERENCES DimRegion(Region_SK),
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE TABLE FactOrders_Error (
    FactError_SK INT IDENTITY(1,1) PRIMARY KEY,
    OrderID_NK INT,
    CustomerID_NK CHAR(5),
    EmployeeID_NK INT,
    ProductID_NK INT,
    ErrorReason NVARCHAR(1000),
    ErrorDate DATETIME DEFAULT GETDATE(),
    SOR_SK INT,
    staging_raw_id_sk INT,
    FOREIGN KEY (SOR_SK) REFERENCES Dim_SOR(SOR_SK)
);
GO

CREATE INDEX IDX_DimCustomers_NK ON DimCustomers(CustomerID_NK);
CREATE INDEX IDX_DimProducts_NK ON DimProducts(ProductID_NK);
CREATE INDEX IDX_DimEmployees_NK ON DimEmployees(EmployeeID_NK);
CREATE INDEX IDX_DimCategories_NK ON DimCategories(CategoryID_NK);
CREATE INDEX IDX_DimRegion_NK ON DimRegion(RegionID_NK);
CREATE INDEX IDX_DimShippers_NK ON DimShippers(ShipperID_NK);
CREATE INDEX IDX_DimSuppliers_NK ON DimSuppliers(SupplierID_NK);
CREATE INDEX IDX_DimTerritories_NK ON DimTerritories(TerritoryID_NK);
CREATE INDEX IDX_FactOrders_OrderID ON FactOrders(OrderID_NK);
GO
