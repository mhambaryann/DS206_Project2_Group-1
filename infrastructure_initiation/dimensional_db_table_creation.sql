-- ============================================
-- DIMENSIONAL DATABASE TABLE CREATION SCRIPT
-- Database: ORDER_DDS
-- Author: Group 3
-- ============================================

USE ORDER_DDS;
GO

/* =========================================================
   DIM_SOR
========================================================= */

CREATE TABLE Dim_SOR (
    SOR_SK INT IDENTITY(1,1) PRIMARY KEY,
    staging_table_name VARCHAR(255) NOT NULL
);
GO

/* =========================================================
   DimCategories
   SCD1 WITH DELETE
========================================================= */

CREATE TABLE DimCategories (
    Category_SK INT IDENTITY(1,1) PRIMARY KEY,

    CategoryID_NK INT NOT NULL,
    CategoryName VARCHAR(255),
    Description VARCHAR(1000),

    IsDeleted BIT DEFAULT 0,

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimCategories_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimCustomers
   SCD2
========================================================= */

CREATE TABLE DimCustomers (
    Customer_SK INT IDENTITY(1,1) PRIMARY KEY,

    CustomerID_NK VARCHAR(10) NOT NULL,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    Phone VARCHAR(50),
    Fax VARCHAR(50),

    StartDate DATETIME NOT NULL,
    EndDate DATETIME,
    IsCurrent BIT DEFAULT 1,

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimCustomers_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimEmployees
   SCD1 WITH DELETE
========================================================= */

CREATE TABLE DimEmployees (
    Employee_SK INT IDENTITY(1,1) PRIMARY KEY,

    EmployeeID_NK INT NOT NULL,
    LastName VARCHAR(255),
    FirstName VARCHAR(255),
    Title VARCHAR(255),
    TitleOfCourtesy VARCHAR(50),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    HomePhone VARCHAR(50),
    Extension VARCHAR(20),
    Notes VARCHAR(MAX),
    ReportsTo INT,

    IsDeleted BIT DEFAULT 0,

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimEmployees_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimProducts
   SCD2 WITH DELETE (CLOSING)
========================================================= */

CREATE TABLE DimProducts (
    Product_SK INT IDENTITY(1,1) PRIMARY KEY,

    ProductID_NK INT NOT NULL,
    ProductName VARCHAR(255),
    SupplierID_NK INT,
    CategoryID_NK INT,
    QuantityPerUnit VARCHAR(255),
    UnitPrice DECIMAL(10,2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT,

    StartDate DATETIME NOT NULL,
    EndDate DATETIME,
    IsCurrent BIT DEFAULT 1,
    IsDeleted BIT DEFAULT 0,

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimProducts_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimRegion
   SCD1
========================================================= */

CREATE TABLE DimRegion (
    Region_SK INT IDENTITY(1,1) PRIMARY KEY,

    RegionID_NK INT NOT NULL,
    RegionDescription VARCHAR(255),

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimRegion_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimShippers
   SCD1
========================================================= */

CREATE TABLE DimShippers (
    Shipper_SK INT IDENTITY(1,1) PRIMARY KEY,

    ShipperID_NK INT NOT NULL,
    CompanyName VARCHAR(255),
    Phone VARCHAR(50),

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimShippers_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimSuppliers
   SCD4
========================================================= */

CREATE TABLE DimSuppliers (
    Supplier_SK INT IDENTITY(1,1) PRIMARY KEY,

    SupplierID_NK INT NOT NULL,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    Phone VARCHAR(50),
    Fax VARCHAR(50),
    HomePage VARCHAR(MAX),

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimSuppliers_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimSuppliers_History
   SUPPORT TABLE FOR SCD4
========================================================= */

CREATE TABLE DimSuppliers_History (
    SupplierHistory_SK INT IDENTITY(1,1) PRIMARY KEY,

    SupplierID_NK INT NOT NULL,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(100),
    Region VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    Phone VARCHAR(50),
    Fax VARCHAR(50),
    HomePage VARCHAR(MAX),

    VersionStartDate DATETIME,
    VersionEndDate DATETIME,

    SOR_SK INT,
    staging_raw_id_sk INT,

    CONSTRAINT FK_DimSuppliersHistory_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   DimTerritories
   SCD3 (CURRENT + PRIOR ATTRIBUTE)
========================================================= */

CREATE TABLE DimTerritories (
    Territory_SK INT IDENTITY(1,1) PRIMARY KEY,

    TerritoryID_NK VARCHAR(20) NOT NULL,
    TerritoryDescription_Current VARCHAR(255),
    TerritoryDescription_Prior VARCHAR(255),
    RegionID_NK INT,

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DimTerritories_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   FactOrders
   SNAPSHOT FACT TABLE
========================================================= */

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

    UnitPrice DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Freight DECIMAL(10,2),

    SnapshotDate DATETIME DEFAULT GETDATE(),

    SOR_SK INT,
    staging_raw_id_sk INT,

    CreatedDate DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_FactOrders_Customers
        FOREIGN KEY (Customer_SK)
        REFERENCES DimCustomers(Customer_SK),

    CONSTRAINT FK_FactOrders_Employees
        FOREIGN KEY (Employee_SK)
        REFERENCES DimEmployees(Employee_SK),

    CONSTRAINT FK_FactOrders_Products
        FOREIGN KEY (Product_SK)
        REFERENCES DimProducts(Product_SK),

    CONSTRAINT FK_FactOrders_Categories
        FOREIGN KEY (Category_SK)
        REFERENCES DimCategories(Category_SK),

    CONSTRAINT FK_FactOrders_Suppliers
        FOREIGN KEY (Supplier_SK)
        REFERENCES DimSuppliers(Supplier_SK),

    CONSTRAINT FK_FactOrders_Shippers
        FOREIGN KEY (Shipper_SK)
        REFERENCES DimShippers(Shipper_SK),

    CONSTRAINT FK_FactOrders_Territories
        FOREIGN KEY (Territory_SK)
        REFERENCES DimTerritories(Territory_SK),

    CONSTRAINT FK_FactOrders_Region
        FOREIGN KEY (Region_SK)
        REFERENCES DimRegion(Region_SK),

    CONSTRAINT FK_FactOrders_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   FactOrders_Error
========================================================= */

CREATE TABLE FactOrders_Error (
    FactError_SK INT IDENTITY(1,1) PRIMARY KEY,

    OrderID_NK INT,

    CustomerID_NK VARCHAR(10),
    EmployeeID_NK INT,
    ProductID_NK INT,

    ErrorReason VARCHAR(1000),
    ErrorDate DATETIME DEFAULT GETDATE(),

    SOR_SK INT,
    staging_raw_id_sk INT,

    CONSTRAINT FK_FactOrdersError_SOR
        FOREIGN KEY (SOR_SK)
        REFERENCES Dim_SOR(SOR_SK)
);
GO

/* =========================================================
   INDEXES
========================================================= */

CREATE INDEX IDX_DimCustomers_NK
ON DimCustomers(CustomerID_NK);
GO

CREATE INDEX IDX_DimProducts_NK
ON DimProducts(ProductID_NK);
GO

CREATE INDEX IDX_DimEmployees_NK
ON DimEmployees(EmployeeID_NK);
GO

CREATE INDEX IDX_FactOrders_OrderID
ON FactOrders(OrderID_NK);
GO

