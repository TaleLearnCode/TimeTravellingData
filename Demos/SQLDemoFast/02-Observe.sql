-- =============================================================================
-- TIME TRAVELLING DATA: SQL Demo (Fast Version)
-- Script 2 of 3: OBSERVE
-- =============================================================================
-- Purpose: Make live changes, watch history accumulate in real-time
-- Duration: ~40 seconds (includes 2 delays of 2 seconds each)
-- Presenter Notes: This is the "wow factor" — show that SQL Server is actually
--                  tracking changes automatically, without any app code.
-- =============================================================================

USE TemporalDemo;
GO

-- =============================================================================
-- SECTION 1: CURRENT STATE
-- =============================================================================
-- Show the current employee roster. Notice ValidFrom/ValidTo are NOT visible.
-- They're there (HIDDEN columns), but SQL Server keeps them out of the way.
-- =============================================================================

SELECT * FROM dbo.Employee ORDER BY EmployeeId;

-- If we want to see the hidden columns, we must request them explicitly:
SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
 ORDER BY EmployeeId;
GO

-- =============================================================================
-- SECTION 2: MAKE A CHANGE — UPDATE
-- =============================================================================
-- Alice is getting a raise! Let's update her salary from $75,000 to $80,000.
-- Watch what happens to the history table.
-- =============================================================================

-- Give Alice a raise
UPDATE dbo.Employee
   SET Salary = 80000.00
 WHERE EmployeeId = 1;
GO

-- Brief pause to create temporal separation (so timestamps differ)
WAITFOR DELAY '00:00:02';
GO

-- Check current table: Alice's salary is now $80,000
SELECT EmployeeId, EmployeeName, JobTitle, Salary
  FROM dbo.Employee
 ORDER BY EmployeeId;

-- Show the hidden period columns: Notice Alice's ValidFrom is very recent
SELECT EmployeeId, EmployeeName, JobTitle, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
 ORDER BY EmployeeId;

-- NOW CHECK THE HISTORY TABLE
-- SQL Server automatically moved the old row (Alice at $75k) to history!
SELECT EmployeeId, EmployeeName, JobTitle, Salary, ValidFrom, ValidTo
  FROM dbo.Employee_History
 ORDER BY EmployeeId, ValidFrom;
GO

-- =============================================================================
-- EXPLANATION: What just happened?
-- =============================================================================
-- When we updated Alice's salary:
--   1. SQL Server ended the old row (set ValidTo to the update timestamp)
--   2. Moved the old row to Employee_History
--   3. Created a new current row with the new salary (ValidFrom = now)
--
-- We didn't write any trigger code. We didn't call a stored procedure.
-- SQL Server did it all automatically because SYSTEM_VERSIONING is ON.
-- =============================================================================

-- =============================================================================
-- SECTION 3: MAKE ANOTHER CHANGE — DELETE
-- =============================================================================
-- Department restructure: David is being let go. When we DELETE his row,
-- does his data disappear forever? NO! It moves to history.
-- =============================================================================

-- Remove David from the current roster
DELETE FROM dbo.Employee
 WHERE EmployeeId = 4;
GO

-- Another brief pause
WAITFOR DELAY '00:00:02';
GO

-- Current table: David is GONE (only 3 employees remain)
SELECT * FROM dbo.Employee ORDER BY EmployeeId;

-- But David's entire employment history is preserved!
SELECT EmployeeId, EmployeeName, JobTitle, Salary, ValidFrom, ValidTo
  FROM dbo.Employee_History
 WHERE EmployeeId = 4
 ORDER BY ValidFrom;
GO

-- =============================================================================
-- SECTION 4: THE RULE OF TWO
-- =============================================================================
-- Two tables, one story:
--   • dbo.Employee       = current state (what IS true right now)
--   • dbo.Employee_History = past states  (what WAS true at various times)
--
-- Together, they form a complete audit trail of every change ever made.
-- =============================================================================

-- CURRENT: The 3 employees who are still here
SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
 ORDER BY EmployeeId;

-- HISTORY: Everyone's past versions, including David who was deleted
SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee_History
 ORDER BY EmployeeId, ValidFrom;
GO

-- =============================================================================
-- OBSERVE COMPLETE
-- =============================================================================
-- What we demonstrated:
--   ✓ UPDATE: Old row moved to history, new row created
--   ✓ DELETE: Row moved to history (nothing is truly lost)
--   ✓ Automatic: No triggers, no app code — SQL Server handles it all
--
-- Current state:
--   • 3 employees in current table (Alice, Bob, Carol)
--   • 5 rows in history table (3 pre-seeded + Alice's $75k Senior Developer row + David's deleted row)
--
-- Next: Run 03-TimeTravel.sql to query "what was true on a specific date"
-- =============================================================================
