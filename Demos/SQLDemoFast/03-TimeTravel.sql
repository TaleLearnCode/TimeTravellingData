-- =============================================================================
-- TIME TRAVELLING DATA: SQL Demo (Fast Version)
-- Script 3 of 3: TIME TRAVEL
-- =============================================================================
-- Purpose: Query historical data using FOR SYSTEM_TIME
-- Duration: ~40 seconds
-- Presenter Notes: This is the payoff. All queries use standard SQL — no 
--                  special drivers, no application code, no magic.
-- =============================================================================

USE TemporalDemo;
GO

-- =============================================================================
-- Now for the time travel.
-- All queries use standard SQL — no special drivers, no special libraries.
-- Just add FOR SYSTEM_TIME to your SELECT statement.
-- =============================================================================

-- =============================================================================
-- QUERY 1: AS OF (Point-in-Time Snapshot)
-- =============================================================================
-- Question: "What did our employee table look like on April 1st, 2024?"
--
-- This was BEFORE:
--   • Alice's promotion to Senior Developer (happened Jul 1)
--   • Carol's conversion from Intern to Junior Developer (happened Jun 15)
--   • David's hiring (he was hired later)
--
-- Expected results: 3 employees
--   • Alice as 'Developer' at $65k (not yet promoted to Senior Developer)
--   • Bob as 'Senior PM' at $110k (not yet restructured to Product Manager)
--   • Carol as 'Intern' at $35k (not yet converted to Junior Developer — hired Mar 1, so she's active Apr 1)
-- =============================================================================

SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
   FOR SYSTEM_TIME AS OF '2024-04-01 14:00:00'
 ORDER BY EmployeeId;
GO

-- =============================================================================
-- EXPLANATION: AS OF returns the state of EVERY row as of that exact moment.
-- It automatically:
--   • Queries both current table AND history table
--   • Filters to rows where ValidFrom <= '2024-04-01' AND ValidTo > '2024-04-01'
--   • Returns the version that was active at that timestamp
--
-- This is like a Git checkout to a specific commit, but for database rows.
-- =============================================================================

-- =============================================================================
-- QUERY 2: BETWEEN (Range Query)
-- =============================================================================
-- Question: "Show all employee versions that were active at ANY point during 
--            the first half of 2024 (Jan 1 - Jun 30)"
--
-- This is useful for auditing: "What was the state of our team in H1?"
--
-- Expected results: Multiple versions of employees
--   • Alice as Developer (started Jan 15, ended Jul 1 — overlaps H1)
--   • Bob as Senior PM (started Jan 15, ended Sep 1 — overlaps H1)
--   • Carol as Intern (started Mar 1, ended Jun 15 — completely within H1)
-- =============================================================================

SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
   FOR SYSTEM_TIME BETWEEN '2024-01-01 00:00:00' AND '2024-06-30 23:59:59'
 ORDER BY EmployeeId, ValidFrom;
GO

-- =============================================================================
-- EXPLANATION: BETWEEN returns rows from BOTH current AND history tables that 
-- overlap with the specified time window.
--
-- A row is included if its validity period (ValidFrom to ValidTo) overlaps 
-- with the query range — even if only partially.
--
-- Great for questions like:
--   • "Who was employed in Q2?"
--   • "What salary changes happened this fiscal year?"
--   • "Show all versions of this record between these dates"
-- =============================================================================

-- =============================================================================
-- QUERY 3: ALL (Complete Audit Trail)
-- =============================================================================
-- Question: "Show me the complete history of every employee — every version, 
--            every change, across all time"
--
-- This is the forensic view. Every row that ever existed.
--
-- Expected results: EVERY version of EVERY employee
--   • Alice: Developer → Senior Developer (2 versions minimum, maybe 3 if we updated her salary in 02-Observe.sql)
--   • Bob: Senior PM → Product Manager (2 versions)
--   • Carol: Intern → Junior Developer (2 versions)
--   • David: Data Analyst (1 version, now in history because we deleted him)
-- =============================================================================

SELECT EmployeeId, EmployeeName, JobTitle, Department, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
   FOR SYSTEM_TIME ALL
 ORDER BY EmployeeId, ValidFrom;
GO

-- =============================================================================
-- EXPLANATION: FOR SYSTEM_TIME ALL is the complete audit trail.
-- It returns:
--   • UNION of current table + history table
--   • Every version of every row that ever existed
--   • Sorted by employee and time
--
-- Notice how each employee's story unfolds chronologically:
--   • Alice: Developer ($65k) from Jan 15 → Senior Developer ($75k) from Jul 1 → $80k from today
--   • Bob: Senior PM ($110k) from Jan 15 → Product Manager ($95k) from Sep 1 → present
--   • Carol: Intern ($35k) from Mar 1 → Junior Developer ($55k) from Jun 15 → present
--   • David: Data Analyst ($65k) from hiring → deleted today
--
-- This is your complete audit log, maintained automatically by SQL Server.
-- =============================================================================

-- =============================================================================
-- ADDITIONAL EXAMPLES (if time permits)
-- =============================================================================

-- "Who was a Senior PM at any point in time?"
SELECT DISTINCT EmployeeId, EmployeeName, JobTitle
  FROM dbo.Employee
   FOR SYSTEM_TIME ALL
 WHERE JobTitle = 'Senior PM';
GO

-- "Show Carol's complete employment history"
SELECT EmployeeName, JobTitle, Salary, ValidFrom, ValidTo
  FROM dbo.Employee
   FOR SYSTEM_TIME ALL
 WHERE EmployeeId = 3
 ORDER BY ValidFrom;
GO

-- "What was the total payroll cost on June 1st, 2024?"
SELECT SUM(Salary) AS TotalPayroll
  FROM dbo.Employee
   FOR SYSTEM_TIME AS OF '2024-06-01 00:00:00';
GO

-- =============================================================================
-- TIME TRAVEL COMPLETE
-- =============================================================================
-- What we demonstrated:
--   ✓ AS OF: Point-in-time snapshot ("state of the world on date X")
--   ✓ BETWEEN: Range query ("all changes during a period")
--   ✓ ALL: Complete audit trail ("every version ever")
--
-- Key takeaways:
--   • Standard SQL syntax (no proprietary extensions beyond FOR SYSTEM_TIME)
--   • Automatic change tracking (no triggers or app code)
--   • Complete history preservation (DELETEs don't destroy data)
--   • Audit compliance built-in (who changed what when)
--
-- Real-world use cases:
--   • Regulatory compliance (GDPR "right to know", SOX auditing)
--   • Debugging ("what was the value when the bug occurred?")
--   • Historical analytics ("revenue trends over time")
--   • Change forensics ("who changed this and when?")
-- =============================================================================

-- =============================================================================
-- CLEANUP: Run this to reset and start fresh
-- =============================================================================
-- Uncomment and run if you want to tear down the demo
-- =============================================================================
/*
ALTER TABLE dbo.Employee SET (SYSTEM_VERSIONING = OFF);
DROP TABLE IF EXISTS dbo.Employee_History;
DROP TABLE IF EXISTS dbo.Employee;
GO
*/

-- To fully remove the database (if not managed by Terraform):
-- DROP DATABASE IF EXISTS TemporalDemo;
-- =============================================================================
