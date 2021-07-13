-- Create a test database.
CREATE DATABASE PartitionDemo
    ON PRIMARY (
         NAME = N'PartitionDemo'
        ,FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\PartitionDemo.mdf'
        ,SIZE = 25MB, FILEGROWTH = 25MB)
    LOG ON (
         NAME = N'PartitionDemo_log'
        ,FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\PartitionDemo_log.ldf'
        ,SIZE = 25MB, FILEGROWTH = 25MB);
GO
USE PartitionDemo;
GO
--— Add filegroups to the Partition demo database.
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup1;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup2;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup3;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup4;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup5;
GO
SELECT * FROM sys.filegroups
GO
-------------------
--— Adds one file for each filegroup.
ALTER DATABASE PartitionDemo
    ADD FILE
    (
        NAME = PartitionFile1,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\File1.ndf',
        SIZE = 25MB, MAXSIZE = 100MB, FILEGROWTH = 5MB
    )
    TO FILEGROUP PartitionDemoFileGroup1;
GO
ALTER DATABASE PartitionDemo
    ADD FILE
    (
        NAME = PartitionFile2,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\File2.ndf',
        SIZE = 25MB, MAXSIZE = 100MB, FILEGROWTH = 5MB
    )
    TO FILEGROUP PartitionDemoFileGroup2;
GO
ALTER DATABASE PartitionDemo
    ADD FILE
    (
        NAME = PartitionFile3,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\File3.ndf',
        SIZE = 25MB, MAXSIZE = 100MB, FILEGROWTH = 5MB
    )
    TO FILEGROUP PartitionDemoFileGroup3;
GO
ALTER DATABASE PartitionDemo
    ADD FILE
    (
        NAME = PartitionFile4,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\File4.ndf',
        SIZE = 25MB, MAXSIZE = 100MB, FILEGROWTH = 5MB
    )
    TO FILEGROUP PartitionDemoFileGroup4;
GO
ALTER DATABASE PartitionDemo
    ADD FILE
    (
        NAME = PartitionFile5,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Partition\File5.ndf',
        SIZE = 25MB, MAXSIZE = 100MB, FILEGROWTH = 5MB
    )
    TO FILEGROUP PartitionDemoFileGroup5;
GO
---
--Create our partition function and then our partition scheme.
