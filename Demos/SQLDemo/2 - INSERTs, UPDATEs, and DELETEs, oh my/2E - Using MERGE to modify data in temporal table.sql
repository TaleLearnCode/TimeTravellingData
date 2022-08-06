-- 2E: Using MERGE to modify data in a temporal table

/*

MERGE operations are supported with the same limitations that INSERT and UPDATE
statements have regarding PERIOD columns.

*/

DECLARE @DepartmentStaging TABLE (DepartmentId INT, DepartmentName VARCHAR(50));
GO

INSERT INTO DepartmentStaging VALUES (1,  'Company Management');
INSERT INTO DepartmentStaging VALUES (10, 'Science & Research');
INSERT INTO DepartmentStaging VALUES (15, 'Process Management');
GO

MERGE Department AS TARGET
USING (SELECT DepartmentId, DepartmentName FROM DepartmentStaging)
AS SOURCE (DepartmentId, DepartmentName)
ON (TARGET.DepartmentId = SOURCE.DepartmentId)
WHEN MATCHED THEN UPDATE SET DepartmentName = SOURCE.DepartmentName
WHEN NOT MATCHED THEN INSERT (DepartmentId,
                              DepartmentName)
					  VALUES (SOURCE.DepartmentId,
					          SOURCE.DepartmentName);