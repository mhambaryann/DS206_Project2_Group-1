/*
Staging Raw Table Creation Script
Author: Member 1
Includes staging_raw_id_sk (IDENTITY) for all tables.
*/

USE ORDER_DDS;
GO

-- Categories
CREATE TABLE dbo.Staging_Categories (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT,
    CategoryName NVARCHAR(255),
    Description NVARCHAR(MAX)
);

-- Customers
CREATE TABLE dbo.Staging_Customers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID CHAR(5),
    CompanyName NVARCHAR(255),
    ContactName NVARCHAR(255),
    ContactTitle NVARCHAR(255),
    Address NVARCHAR(255),
    City NVARCHAR(255),
    Region NVARCHAR(255),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(100),
    Phone NVARCHAR(50),
    Fax NVARCHAR(50)
);

-- Employees
CREATE TABLE dbo.Staging_Employees (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
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
    PhotoPath NVARCHAR(255)
);

-- OrderDetails
CREATE TABLE dbo.Staging_OrderDetails (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(5,2)
);

-- Orders
CREATE TABLE dbo.Staging_Orders (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    CustomerID CHAR(5),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight DECIMAL(18,2),
    ShipName NVARCHAR(255),
    ShipAddress NVARCHAR(255),
    ShipCity NVARCHAR(255),
    ShipRegion NVARCHAR(255),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(100),
    TerritoryID NVARCHAR(100)
);

-- Products
CREATE TABLE dbo.Staging_Products (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductName NVARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(255),
    UnitPrice DECIMAL(18,2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT
);

-- Region
CREATE TABLE dbo.Staging_Region (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    RegionID INT,
    RegionDescription NVARCHAR(255),
    RegionCategory NVARCHAR(255),
    RegionImportance NVARCHAR(255)
);

-- Shippers
CREATE TABLE dbo.Staging_Shippers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    ShipperID INT,
    CompanyName NVARCHAR(255),
    Phone NVARCHAR(50)
);

-- Suppliers
CREATE TABLE dbo.Staging_Suppliers (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT,
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
    HomePage NVARCHAR(MAX)
);

-- Territories
CREATE TABLE dbo.Staging_Territories (
    staging_raw_id_sk INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryID NVARCHAR(50),
    TerritoryDescription NVARCHAR(255),
    TerritoryCode NVARCHAR(50),
    RegionID INT
);
GO
