--Step 1: Create a Demo database.
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
--—Step 2: Add filegroups to the Partition demo database.
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup1;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup2;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup3;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup4;
ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup5;
GO
SELECT * FROM sys.filegroups
GO
-------------------
--— Step 3: Adds one file for each filegroup.
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
---------------------------------------------------------------------------------
--Step 4: Create our partition function that will partition our table into five partitions.
CREATE PARTITION FUNCTION DemoRangePartFunc (int)
    AS RANGE LEFT FOR VALUES (500, 1000, 1500, 2000);
GO
---------------------------------------------------------------------------------
--Step 5: Creates a partition scheme called myRangePS1 that applies RangeParFunc to the five filegroups created above
CREATE PARTITION SCHEME DemoRangePartScheme
	AS PARTITION DemoRangePartFunc
	TO (PartitionDemoFileGroup1,PartitionDemoFileGroup2,PartitionDemoFileGroup3,PartitionDemoFileGroup4,PartitionDemoFileGroup5);
GO

--Step 6: Creates a partitioned table called PartitionTable1 with a clustered index
--DROP TABLE PartitionTable1
CREATE TABLE PartitionTable1 (Id int IDENTITY(1,1), HireDate datetime, Descr VARCHAR(8000))
    ON DemoRangePartScheme (Id);
GO
CREATE CLUSTERED INDEX [PK_ID] ON [dbo].[PartitionTable1]
    (Id ASC) ON DemoRangePartScheme(Id);
GO

--Step 7: Creates a partitioned table called PartitionTable2 with a nonclustered index
CREATE TABLE PartitionTable2 (Id int IDENTITY(1,1), HireDate datetime, Descr VARCHAR(8000))
    ON DemoRangePartScheme (Id);
GO
CREATE NONCLUSTERED INDEX [IX_ID_HireDate] ON [dbo].[PartitionTable2]
    (Id,HireDate ASC) ON DemoRangePartScheme(Id);
GO

--Step 8: Add 3500 rows of dummy data to each table
INSERT PartitionTable1(HireDate,Descr)
SELECT  CAST(CAST(GETDATE() AS INT) -2000 * RAND(CAST(CAST(NEWID() AS BINARY(8)) AS INT))AS DATETIME), REPLICATE('1',8000);
GO 3500
-----------
INSERT PartitionTable2(HireDate,Descr)
SELECT  CAST(CAST(GETDATE() AS INT) -2000 * RAND(CAST(CAST(NEWID() AS BINARY(8)) AS INT))AS DATETIME), REPLICATE('2',8000);
GO 3500
------------------------------------------------------

-- Get partition information.
SELECT
     --SCHEMA_NAME(t.schema_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS ObjectName
    ,p.partition_number AS PartitionNumber
    ,fg.name AS Filegroup_Name
    ,rows AS 'Rows'
    ,au.total_pages AS 'TotalDataPages'
    ,CASE boundary_value_on_right
        WHEN 1 THEN '<'
        ELSE '<='
     END AS 'Comparison'
    ,value AS 'ComparisonValue'
   -- ,p.data_compression_desc AS 'DataCompression'
   -- ,p.partition_id
FROM sys.partitions p
    JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
    JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
    JOIN sys.partition_functions f ON f.function_id = ps.function_id
    LEFT JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
    JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id =ps.data_space_id AND dds.destination_id = p.partition_number
    JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
    JOIN (SELECT container_id, sum(total_pages) as total_pages
            FROM sys.allocation_units
            GROUP BY container_id) AS au ON au.container_id = p.partition_id 
    JOIN sys.tables t ON p.object_id = t.object_id
WHERE i.index_id < 2
ORDER BY ObjectName,p.partition_number;
GO
/* 
-----------------------------------------------------------------------------------------------------------
ObjectName		PartitionNumber	Filegroup_Name			 Rows	 TotalDataPages	Comparison	ComparisonValue
-----------------------------------------------------------------------------------------------------------
PartitionTable1	     1			PartitionDemoFileGroup1	 500	     505		   <=	       500
PartitionTable1	     2			PartitionDemoFileGroup2	 500	     505		   <=	       1000
PartitionTable1	     3			PartitionDemoFileGroup3	 500	     505		   <=	       1500
PartitionTable1	     4			PartitionDemoFileGroup4	 500	     505		   <=	       2000
PartitionTable1	     5	        PartitionDemoFileGroup5	 1500	     1513		   <=	       NULL

PartitionTable2	     1	        PartitionDemoFileGroup1	 500	     505		   <=	       500
PartitionTable2	     2	        PartitionDemoFileGroup2	 500	     505		   <=	       1000
PartitionTable2	     3	        PartitionDemoFileGroup3	 500	     505		   <=	       1500
PartitionTable2	     4	        PartitionDemoFileGroup4	 500	     505		   <=	       2000
PartitionTable2	     5	        PartitionDemoFileGroup5	 1500	     1505		   <=	       NULL
*/
---------------------------
--Step 9: Undo-table-partitioning
/*
	-- Undo partitioning when table has clustered index
	Credit: https://www.patrickkeisler.com/2013/01/how-to-remove-undo-table-partitioning.html
	When table has partitioned clustered index, Undo table partitioning is very easy.
	-- CREATE INDEX using the DROP_EXISTING option and specifying a different filegroup.  
	This will drop the current partitioned index (which includes the data) and recreate it on the PRIMARY filegroup all within a single command.
*/
-- Quick and easy way to unpartition and move it when table has clustered index
CREATE CLUSTERED INDEX [PK_ID]
    ON [dbo].[PartitionTable1](Id)
    WITH (DROP_EXISTING = ON)
    ON [PRIMARY];
GO

/*
	-- Undo partitioning when table does not have clustered index
	Credit: https://www.patrickkeisler.com/2013/01/how-to-remove-undo-table-partitioning.html
	When table has does not have partitioned clustered index, we have to use use a ALTER commands such as MERGE RANGE, NEXT USED, SPLIT RANGE, and SWITCH.
	--S1: First we need to use the ALTER PARTITION FUNCTION MERGE command to combine all of the four partitions into a single partition.  
		The MERGE RANGE command removes the boundary point between the specified partitions.

	--S2: Specify the PRIMARY filegroup as the next partition using `ALTER PARTITION SCHEME NEXT USED`

	--S3:use ALTER PARTITION FUNCTION SPLIT RANGE using a partition value that is larger than the maximum value of partition column.  
		The SPLIT RANGE command will create a new boundary in the partitioned table.

	--S4: Create a non-partitioned table in the PRIMARY filegroup that matches the PartitionTable2 in every way, including any data types, constraints, etc.  
		  This new table will only be used as a temporary holding location for the data.		

	--S5: Move all the rows into the NonPartitionTable using ALTER TABLE SWITCH

	--S6: Drop the partitioned table and rename  temporary table to the original name.
GO
*/
-- Merge all partitions into a single partition.
ALTER PARTITION FUNCTION DemoRangePartFunc() MERGE RANGE (500);
GO
ALTER PARTITION FUNCTION DemoRangePartFunc() MERGE RANGE (1000);
GO
ALTER PARTITION FUNCTION DemoRangePartFunc() MERGE RANGE (1500);
GO
ALTER PARTITION FUNCTION DemoRangePartFunc() MERGE RANGE (2000);
GO
--use ALTER PARTITION SCHEME NEXT USED to specify the PRIMARY filegroup as the next partition.
ALTER PARTITION SCHEME DemoRangePartScheme NEXT USED [PRIMARY];
GO
--Split the single partition into 2 separates ones to push all data to the PRIMARY FG.
ALTER PARTITION FUNCTION DemoRangePartFunc() SPLIT RANGE (3500);
GO
--create a non-partitioned table in the PRIMARY filegroup that matches the PartitionTable2 in every way, including any data types, constraints, etc.  
--This new table will only be used as a temporary holding location for the data.
--DROP TABLE NonPartitionTable2
CREATE TABLE NonPartitionTable2 (Id int IDENTITY(1,1), HireDate datetime, Descr VARCHAR(8000))
    ON [PRIMARY];
GO
--DROP INDEX [IX_ID_HireDate_2] ON NonPartitionTable2
CREATE NONCLUSTERED INDEX [IX_ID_HireDate_2] ON [dbo].NonPartitionTable2
    (Id,HireDate ASC) ON [PRIMARY];
GO
--use the ALTER TABLE SWITCH command to move all the rows of data into the NonPartitionTable2.
ALTER TABLE PartitionTable2 SWITCH PARTITION 1 TO NonPartitionTable2;
GO
-- Drop the partitioned table.
DROP TABLE PartitionTable2
-- Rename the temporary table to the original name.
EXEC sp_rename 'dbo.NonPartitionTable2', 'PartitionTable2', 'OBJECT';

--Step 10: Remove the partition scheme, function, files, and filegroups.
DROP PARTITION SCHEME DemoRangePartScheme;
GO
DROP PARTITION FUNCTION DemoRangePartFunc;
GO
ALTER DATABASE PartitionDemo REMOVE FILE PartitionFile1;
ALTER DATABASE PartitionDemo REMOVE FILE PartitionFile2;
ALTER DATABASE PartitionDemo REMOVE FILE PartitionFile3;
ALTER DATABASE PartitionDemo REMOVE FILE PartitionFile4;
ALTER DATABASE PartitionDemo REMOVE FILE PartitionFile5;
GO
ALTER DATABASE PartitionDemo REMOVE FILEGROUP PartitionDemoFileGroup1;
ALTER DATABASE PartitionDemo REMOVE FILEGROUP PartitionDemoFileGroup2;
ALTER DATABASE PartitionDemo REMOVE FILEGROUP PartitionDemoFileGroup3;
ALTER DATABASE PartitionDemo REMOVE FILEGROUP PartitionDemoFileGroup4;
ALTER DATABASE PartitionDemo REMOVE FILEGROUP PartitionDemoFileGroup5;
GO
