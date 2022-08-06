-- 3D: Cleaning up history

/*

You might want to limit the amount of history that is being kept.  The history
table could otherwise grow enormously and become too expensive to maintain.

*/

ALTER TABLE Inventory
  SET (SYSTEM_VERSIONING = OFF);
GO

DELETE FROM Inventory_History
WHERE ValidTo <= '2016-09-03 06:47:56';
GO

ALTER TABLE Inventory
  SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Inventory_History));
GO







-- Enable temporal history retention
ALTER DATABASE CURRENT
SET TEMPORAL_HISTORY_RETENTION ON
GO

-- Set the length of the retention period for the Inventory table
ALTER TABLE Inventory
  SET (SYSTEM_VERSIONING = ON (HISTORY_RETENTION_PERIOD = 30 DAYS));