-- 1A: Creating a temporal table with an anonymous history table

/*
 Creating a temporal table with an "anonymous" history table is a convenient option for quick object creation,
 especially in prototypes and test environments.  It also the easiest way to create a temporal table since it
 does not require any parameter in the SYSTEM_VERSIONING clause
*/

CREATE TABLE AnonymousDepartment
(
  DepartmentId       INT                                     NOT NULL,
  DepartmentName     VARCHAR(50)                             NOT NULL,
  ManagerId          INT                                         NULL,
  ParentDepartmentId INT                                         NULL,
  ValidFrom          DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo            DATETIME2 GENERATED ALWAYS AS ROW END   NOT NULL,
  PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
  CONSTRAINT pkcAnonymousDepartment PRIMARY KEY CLUSTERED (DepartmentId)
) WITH (SYSTEM_VERSIONING = ON)

/*
 The anonymous history table has the following format:  MSSQL_TemporalHistoryFor_{ObjectId}

 A default clustered index is created for the history table with an auto-generated name in the format of
 ix_MSSQL_TemporalHistoryFor_{ObjectId}
*/