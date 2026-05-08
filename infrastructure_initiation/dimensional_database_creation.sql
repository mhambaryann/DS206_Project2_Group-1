/*
Dimensional Database Creation Script
*/

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ORDER_DDS')
BEGIN
    CREATE DATABASE ORDER_DDS;
END
GO
