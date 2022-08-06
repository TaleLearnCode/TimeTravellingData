-- Updating the current table from the history table

/*
You can use UPDATE on the current table to revert the actual row state to a
valid state at a specified point in time in the past (reverting to a "last good
known row version").  The following example shows reverting to the values
in the history table
*/

--SELECT * FROM Department
--SELECT * FROM DepartmentHistory

UPDATE Department
   SET DepartmentName = History.DepartmentName
  FROM Department
   FOR SYSTEM_TIME AS OF '2022-08-06 13:34:24' AS History
 WHERE History.DepartmentId = 10
   AND Department.DepartmentId = 10