-- 1E: Adding Versioning to Non-Temporal Tables

/*
 If you want to start tracking changes for a non-temporal table that contains data, you need to add the PERIOD
 definition and optionally provide a name for the empty history table that SQL sServer will create for you.
*/

CREATE TABLE OldDepartment
(
  DepartmentId       INT                                     NOT NULL,
  DepartmentName     VARCHAR(50)                             NOT NULL,
  ManagerId          INT                                         NULL,
  ParentDepartmentId INT                                         NULL,
  CONSTRAINT pkcOldDepartment PRIMARY KEY CLUSTERED (DepartmentId)
) WITH (SYSTEM_VERSIONING = ON)
GO

ALTER TABLE OldDepartment
        ADD ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT dfOldDepartment_ValidFrom DEFAULT SYSUTCDATETIME(),
            ValidTo   DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN CONSTRAINT dfOldDepartment_ValidTo   DEFAULT CONVERT(DATETIME2 (0), '9999-12-31 23:59:59'),
            PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
GO

ALTER TABLE OldDepartment SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = History.OldDepartmentHistory));

/*

 Adding a non-null column can be an expensive operation

 Constraints for period start and period end columns must be chosen carefully:
 * Default for the start column specifies from which point in time your consider existing rows to be valid.  It
   cannot be specified as a DATETIME2 point in the future.
 * End time must be specified as the maximum value for a given DATETIME2 precision

 Adding a period will perform a data consistency check on the current table to make sure that the defaults for
 period columns are valid

 When an existing history table is specified when enabling SYSTEM_VERSIONING, a data consistency check will be
 performed across both the current and the history table.  It can be skipped if your specify DATE_CONSISTENCY_CHECK = OFF as an additional parameter.

*/