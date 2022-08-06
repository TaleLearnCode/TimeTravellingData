-- Updating the current table

/*
In this example, the ManagerId column is updated for each row where
DepartmentId = 10.  The PERIOD columns are not referenced in any way.
*/

UPDATE Department
   SET ManagerId = 501
 WHERE DepartmentId = 10

 /*

 However, you cannot update a PERIOD column and you cannot update the
 history table.  In this example, an attempt to update a PERIOD column
 generates an error.

 */

 UPDATE Department
    SET ValidFrom = '2015-09-23 23:48:31.2990175'
  WHERE DepartmentId = 10