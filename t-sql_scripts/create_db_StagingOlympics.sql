USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'StagingOlympics')
BEGIN
    ALTER DATABASE StagingOlympics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StagingOlympics;
END
GO

-- Tạo mới database
CREATE DATABASE StagingOlympics;
GO

USE StagingOlympics;
GO