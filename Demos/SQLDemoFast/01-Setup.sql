-- =============================================================================
-- TIME TRAVELLING DATA: SQL Demo (Fast Version)
-- Script 1 of 3: SETUP
-- =============================================================================
-- Purpose: Create temporal table, insert current employees, pre-seed history
-- Duration: ~20 seconds
-- Presenter Notes: Database 'TemporalDemo' is provisioned by Terraform.
--                  Connect to it in SSMS before running this script.
-- =============================================================================

USE TemporalDemo;
GO

-- Drop existing tables if present (for clean re-runs)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee' AND temporal_type = 2)
BEGIN
    ALTER TABLE dbo.Employee SET (SYSTEM_VERSIONING = OFF);
END
GO

DROP TABLE IF EXISTS dbo.Employee_History;
DROP TABLE IF EXISTS dbo.Employee;
GO

-- =============================================================================
-- CREATE TEMPORAL TABLE: Employee
-- =============================================================================
-- Why Employee domain? For a developer/DBA audience, tracking "who was in what 
-- role on date X" is more compelling than product pricing. Promotions, 
-- department changes, and departures create a clear human narrative.
--
-- Key features:
--   • HIDDEN period columns: ValidFrom/ValidTo aren't shown in SELECT * queries
--   • Named history table: dbo.Employee_History (better than auto-generated name)
--   • System versioning: SQL Server automatically tracks all changes
-- =============================================================================

CREATE TABLE dbo.Employee
(
    EmployeeId   INT            NOT NULL,
    EmployeeName NVARCHAR(100)  NOT NULL,
    JobTitle     NVARCHAR(100)  NOT NULL,
    Department   NVARCHAR(50)   NOT NULL,
    Salary       DECIMAL(10,2)  NOT NULL,
    
    -- Period columns: SQL Server manages these automatically
    ValidFrom    DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo      DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT pk_Employee PRIMARY KEY CLUSTERED (EmployeeId)
) 
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Employee_History));
GO

-- =============================================================================
-- INSERT CURRENT EMPLOYEES
-- =============================================================================
-- These are the employees currently in the system (as of demo run time)
-- Notice we DON'T specify ValidFrom/ValidTo — SQL Server handles that
-- =============================================================================

INSERT INTO dbo.Employee (EmployeeId, EmployeeName, JobTitle, Department, Salary)
VALUES 
    (1, 'Alice Johnson', 'Senior Developer', 'Engineering', 75000.00),
    (2, 'Bob Smith',      'Product Manager',  'Product',     95000.00),
    (3, 'Carol White',    'Junior Developer', 'Engineering', 55000.00),
    (4, 'David Brown',    'Data Analyst',     'Analytics',   65000.00);
GO

-- =============================================================================
-- PRE-SEED HISTORICAL DATA
-- =============================================================================
-- Why? For demo purposes, we want queries to return predictable results with
-- known timestamps. This technique gives us "instant history" without waiting.
--
-- The Story We're Telling:
--   • Alice: Started as 'Developer' ($65k), promoted to 'Senior Developer' ($75k)
--   • Bob: Was 'Senior PM' ($110k), restructured to 'Product Manager' ($95k)
--   • Carol: Started as 'Intern' ($35k), converted to 'Junior Developer' ($55k)
--   • David: Hired recently (no history — his current row IS his first row)
--
-- Technique:
--   1. Turn OFF system versioning
--   2. Insert rows directly into history table with hardcoded timestamps
--   3. Turn system versioning back ON
-- =============================================================================

-- Step 1: Turn off versioning to allow manual history inserts
ALTER TABLE dbo.Employee SET (SYSTEM_VERSIONING = OFF);
GO

-- Step 2: Insert historical rows
-- Format: (EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo)

-- Alice's history: Was a Developer from Jan 15 until her promotion on Jul 1
INSERT INTO dbo.Employee_History 
    (EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo)
VALUES 
    (1, 'Alice Johnson', 'Developer', 'Engineering', 65000.00, 
     '2024-01-15 09:00:00', '2024-07-01 09:00:00');

-- Bob's history: Was a Senior PM from Jan 15 until org restructure on Sep 1
INSERT INTO dbo.Employee_History 
    (EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo)
VALUES 
    (2, 'Bob Smith', 'Senior PM', 'Product', 110000.00, 
     '2024-01-15 09:00:00', '2024-09-01 09:00:00');

-- Carol's history: Was an Intern from Mar 1 until conversion on Jun 15
INSERT INTO dbo.Employee_History 
    (EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo)
VALUES 
    (3, 'Carol White', 'Intern', 'Engineering', 35000.00, 
     '2024-03-01 09:00:00', '2024-06-15 09:00:00');

-- David has NO history — he was hired recently and this is his first position
GO

-- Step 3: Re-enable system versioning
-- From now on, SQL Server will automatically track changes again
ALTER TABLE dbo.Employee SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Employee_History));
GO

-- =============================================================================
-- VERIFY SETUP
-- =============================================================================
-- Quick check: Show current employees and pre-seeded history
-- =============================================================================

-- Current employees (ValidFrom/ValidTo are HIDDEN — won't show in SELECT *)
SELECT * FROM dbo.Employee ORDER BY EmployeeId;

-- Pre-seeded history (explicitly request hidden columns to see timestamps)
SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee_History
 ORDER BY EmployeeId, ValidFrom;
GO

-- =============================================================================
-- SETUP COMPLETE
-- =============================================================================
-- What we have now:
--   ✓ 4 current employees in dbo.Employee
--   ✓ 3 historical records in dbo.Employee_History (pre-seeded with known dates)
--   ✓ System versioning is ON (future changes will be tracked automatically)
--
-- Next: Run 02-Observe.sql to see live changes being tracked in real-time
-- =============================================================================
