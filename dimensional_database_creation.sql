/*
Dimensional Database Creation Script
Author: Member 1
*/

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ORDER_DDS')
BEGIN
    CREATE DATABASE ORDER_DDS;
END
GO
