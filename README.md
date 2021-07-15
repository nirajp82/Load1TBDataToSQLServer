# Load Terabytes of data To SQLServer
Using SSIS to load 1TB data into SQL Server, with simplified settings

### Table Partitioning in SQL Server – Step by Step
* Create a File Group
* Add Files to File Group
* Create a Partition Function with Ranges
* Create a Partition Schema with File Groups

##### **What is a Filegroup?**
A filegroup is a logical structure to group objects in a database. Don’t confuse filegroups with actual files (.mdf, .ddf, .ndf, .ldf, etc.). You can have multiple filegroups per database. One filegroup will be the primary, and all system tables are stored on it. Then, you add additional filegroups. You can specify one filegroup as the default, and objects not specifically assigned to a filegroup will exist in the default. In a filegroup, you can have multiple files.

For example: file1.ndf, file2.ndf, and file3.ndf can be made on three disk drives, separately, and assigned to the filegroup fgroup1. A table would be created explicitly on the filegroup fgroup1. Queries for data from the table will be spread over the three disks; it will improve execution. A similar performance improvement can be practiced by using a solitary file made on a RAID (Redundant Array of Independent Disk) stripe set. Be that as it may, files and filegroups let you effectively add new files to new disks.

** How to create file group
   ```ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup1;```
** How view file group
   ```SELECT * FROM sys.filegroups```

##### **Heaps**
A heap is a table without a clustered index. One or more nonclustered indexes can be created on tables stored as a heap. Data is stored in the heap without specifying an order. Usually data is initially stored in the order in which is the rows are inserted into the table, but the Database Engine can move data around in the heap to store the rows efficiently; so the data order cannot be predicted. To guarantee the order of rows returned from a heap, you must use the ORDER BY clause. To specify a permanent logical order for storing the rows, create a clustered index on the table, so that the table is not a heap.

#####  **Partition Function**
Partition function maps the rows of a table or index into partitions based on the values of a specified column. Using CREATE PARTITION FUNCTION is the first step in creating a partitioned table or index. In SQL Server, a table or index can have a maximum of 15,000 partitions.
** Creating a RANGE LEFT partition function on an int column
The following partition function will partition a table or index into four partitions.
```
CREATE PARTITION FUNCTION myRangePF1 (int)  
AS RANGE LEFT FOR VALUES (1, 100, 1000);
```
| Partition 1    | Partition 2     | Partition 3      | Partition: 4     |
| -------------- |:--------------: | :---------------: | :------------------: |
| col1 <= 1      |  col1 > 1 AND col1 <= 100 |col1 > 100 AND col1 <=1000	 | col1 > 1000 |

#### **PARTITION SCHEME** 
Partition Scheme maps the partitions of a partitioned table or index to filegroups. The number and domain of the partitions of a partitioned table or index are determined in a partition function. A partition function must first be created in a CREATE PARTITION FUNCTION statement before creating a partition scheme.

  
### References
* https://techcommunity.microsoft.com/t5/sql-server-integration-services/using-ssis-to-load-1tb-data-into-sql-server-in-30-mins-with/ba-p/388322
* https://www.patrickkeisler.com/2013/01/how-to-remove-undo-table-partitioning.html
* https://www.emaildoctor.org/blog/what-are-files-and-filegroups-in-sql-server/
* https://blogs.lessthandot.com/index.php/datamgmt/dbadmin/sql-server-filegroups-the-what/
* https://docs.microsoft.com/en-us/sql/relational-databases/indexes/heaps-tables-without-clustered-indexes?view=sql-server-ver15
* https://docs.microsoft.com/en-us/sql/t-sql/statements/create-partition-function-transact-sql?view=sql-server-ver15
* https://www.sqlshack.com/how-to-automate-table-partitioning-in-sql-server/
