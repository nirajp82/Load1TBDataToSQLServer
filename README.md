# Load1 Terabytes of data To SQLServer
Using SSIS to load 1TB data into SQL Server, with simplified settings

##### What is a Filegroup?
* A filegroup is a logical structure to group objects in a database. Don’t confuse filegroups with actual files (.mdf, .ddf, .ndf, .ldf, etc.). You can have multiple filegroups per database. One filegroup will be the primary, and all system tables are stored on it. Then, you add additional filegroups. You can specify one filegroup as the default, and objects not specifically assigned to a filegroup will exist in the default. In a filegroup, you can have multiple files.
* For example: file1.ndf, file2.ndf, and file3.ndf can be made on three disk drives, separately, and assigned to the filegroup fgroup1. A table would be created explicitly on the filegroup fgroup1. Queries for data from the table will be spread over the three disks; it will improve execution. A similar performance improvement can be practiced by using a solitary file made on a RAID (Redundant Array of Independent Disk) stripe set. Be that as it may, files and filegroups let you effectively add new files to new disks.
* How to create file group
   ```ALTER DATABASE PartitionDemo ADD FILEGROUP PartitionDemoFileGroup1;```
 * How view file group
   ```SELECT * FROM sys.filegroups```


### References
* https://techcommunity.microsoft.com/t5/sql-server-integration-services/using-ssis-to-load-1tb-data-into-sql-server-in-30-mins-with/ba-p/388322
* https://www.patrickkeisler.com/2013/01/how-to-remove-undo-table-partitioning.html
* https://www.emaildoctor.org/blog/what-are-files-and-filegroups-in-sql-server/
* https://blogs.lessthandot.com/index.php/datamgmt/dbadmin/sql-server-filegroups-the-what/
