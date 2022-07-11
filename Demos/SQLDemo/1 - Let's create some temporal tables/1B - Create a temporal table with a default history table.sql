-- 1B: Creating a temporal table with a user-defined history table

/*
 Creating a temporal table with a user-defined history table is a convenient option when you want to specify a
 history table with specified storage options and additional indexes.
*/

CREATE TABLE DefaultDepartment
(
  DepartmentId       INT                                     NOT NULL,
  DepartmentName     VARCHAR(50)                             NOT NULL,
  ManagerId          INT                                         NULL,
  ParentDepartmentId INT                                         NULL,
  ValidFrom          DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  ValidTo            DATETIME2 GENERATED ALWAYS AS ROW END   NOT NULL,
  PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
  CONSTRAINT pkcDefaultDepartment PRIMARY KEY CLUSTERED (DepartmentId)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DefaultDepartmentHistory))

/*

 The history table is created using the same rules that apply to creating an anonymous history table, with the
 following rules that apply specifically to the named history table:

 * The schema name is mandatory for the HISTORY_TABLE parameter
 * If the specified schema does not exist, the CREATE TABLE statement will fail
 * If the table specified by the HISTORY_TABLE parameter already exists, it will be validated against the newly
   created temporal table in terms of schema consistency and temporal data consistency. If you specify an invalid
   history table, the CREATE TABLE statement will fail.

*/