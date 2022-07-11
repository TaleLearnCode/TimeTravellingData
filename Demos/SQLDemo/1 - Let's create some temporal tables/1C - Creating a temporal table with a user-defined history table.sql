-- 1C: Creating a temporal table with a user-defined history table

/*
 Creating a temporal table with a user-defined history table is a convenient option when the user wants to
 specify a history table with specified storage options and additional indexes.
*/

CREATE TABLE dbo.DepartmentHistory
(
  DepartmentId       INT         NOT NULL,
  DepartmentName     VARCHAR(50) NOT NULL,
  ManagerId          INT             NULL,
  ParentDepartmentId INT             NULL,
  ValidFrom          DATETIME2   NOT NULL,
  ValidTo            DATETIME2   NOT NULL,
)
GO

CREATE CLUSTERED COLUMNSTORE INDEX ixDepartmentHistory ON dbo.DepartmentHistory;
CREATE NONCLUSTERED INDEX ixDepartmentHistgory_Period ON dbo.DepartmentHistory (ValidFrom, ValidTo, DepartmentId);
GO

CREATE TABLE Department
(
  DepartmentId       INT                                     NOT NULL,
  DepartmentName     VARCHAR(50)                             NOT NULL,
  ManagerId          INT                                         NULL,
  ParentDepartmentId INT                                         NULL,
  ValidFrom          DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo            DATETIME2 GENERATED ALWAYS AS ROW END   NOT NULL,
  PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
  CONSTRAINT pkcDepartment PRIMARY KEY CLUSTERED (DepartmentId)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DepartmentHistory))
GO

/*

 In this example, a user-defined history table is created with a schema that is aligned with the temporal table
 that will be created. A clustered column-store index and additional non-clustered row-store index is added to
 the history table for point lookups.  After this user-defined history table is created, the system-versioned
 temporal table is created specifying the user-defined history table as the default history table.

If you plan to run analytic queries on the historical data that employs aggregates or windowing functions, creating
a clustered column store as a primary index is highly recommended for compression and query performance.

If the primary use case is data audit (i.e. searching for historical changes for a single row from the current table),
then a good choice is to create rowstore history table with a clustered index

The history table cannot have a primary key, foreign keys, unique indexes, table constraints or triggers.  It
cannot be configured for change data capture, change tracking, transitional or merge replication.

*/