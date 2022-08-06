-- 2D: Deleting Data

/*
You delete data in the current table with a regular DELETE statement.  The end
period column for deleted rows will be populated with the begin time of the
underlying transaction.
*/

SELECT * FROM CompanyLocation
SELECT * FROM CompanyLocation_History

DELETE FROM CompanyLocation WHERE CompanyLocationName = 'Headquarters'


/*

You cannot directly delete rows from the history table while SYSTEM_VERSIONIONG = ON.
Set SYSTEM_VERSIONING = OFF and delete rows from current and history table but
keep in mind that the system will not preserve the history of changes.
*/