# SQL Demo Fast — Temporal Tables in 2 Minutes

This demo showcases SQL Server temporal tables using an **Employee** domain. It demonstrates automatic change tracking, history preservation, and time-travel queries in Azure SQL Database.

## What This Demo Shows

- **Automatic Change Tracking**: SQL Server captures every UPDATE and DELETE without triggers or application code
- **History Preservation**: Deleted rows are preserved, not lost
- **Time-Travel Queries**: Query "what was true on date X" using standard SQL
- **Audit Compliance**: Built-in audit trail for regulatory requirements

## Prerequisites

### Option 1: Use Azure SQL (Recommended)

1. **Provision infrastructure** with Terraform (see `../FastSetup/terraform/README.md`)
2. **Connect via SSMS** using the output from `terraform output ssms_connection_info`

### Option 2: Use Local SQL Server

1. **SQL Server 2016+** (Temporal tables require 2016 or later)
2. **SQL Server Management Studio (SSMS)** — Download from https://aka.ms/ssms

## Demo Execution

Run the scripts **in order**. Total time: ~2 minutes.

### Script 1: `01-Setup.sql` (~20 seconds)

**What it does:**
- Creates `dbo.Employee` temporal table with system versioning
- Inserts 4 current employees (Alice, Bob, Carol, David)
- Pre-seeds history table with known timestamps for predictable query results

**Key talking points:**
- "HIDDEN columns keep ValidFrom/ValidTo out of the way"
- "SYSTEM_VERSIONING = ON means SQL Server tracks changes automatically"
- "We're pre-seeding some history so queries return interesting results"

**Expected results:**
- 4 employees in current table
- 3 historical records (Alice, Bob, Carol's previous roles)

---

### Script 2: `02-Observe.sql` (~40 seconds)

**What it does:**
- **UPDATE**: Gives Alice a $5,000 raise (watch her old salary move to history)
- **DELETE**: Removes David from the roster (watch his record move to history)
- Shows both current and history tables side-by-side

**Key talking points:**
- "Watch what happens when I update Alice's salary — no trigger code, no app logic"
- "SQL Server automatically ended the old row and created a new one"
- "When I delete David, his data isn't lost — it moves to history"
- "Two tables, one story: current + history = complete audit trail"

**Expected results:**
- 3 employees in current table (Alice, Bob, Carol — David is gone)
- 5 rows in history table (3 pre-seeded + Alice's old $75k salary + David's deleted row)

---

### Script 3: `03-TimeTravel.sql` (~40 seconds)

**What it does:**
- **AS OF**: Point-in-time query ("What was true on April 1st, 2024?")
- **BETWEEN**: Range query ("Show changes during H1 2024")
- **ALL**: Complete audit trail ("Show every version of every employee")

**Key talking points:**

**Query 1 — AS OF:**
- "This is like Git checkout for database rows"
- "Shows Alice as 'Developer' before her promotion, Carol as 'Intern' before conversion"
- "David doesn't exist yet — he was hired later"

**Query 2 — BETWEEN:**
- "Useful for auditing: 'What changed in Q2?'"
- "Returns rows from current AND history that overlap with the date range"

**Query 3 — ALL:**
- "This is the complete forensic view"
- "Every version of every employee, sorted chronologically"
- "Notice how each employee's career unfolds in the results"

**Expected results:**

| Query | Expected Row Count | Key Insight |
|-------|-------------------|-------------|
| AS OF '2024-04-01' | 3 rows | Alice (Developer $65k), Bob (Senior PM $110k), Carol (Intern $35k) |
| BETWEEN '2024-01-01' AND '2024-06-30' | 3 rows | Alice, Bob, Carol's H1 versions |
| ALL | 7+ rows | Complete history of all employees |

---

## Timing Guide

| Section | Time | Cumulative |
|---------|------|------------|
| 01-Setup.sql | 20s | 20s |
| 02-Observe.sql | 40s | 1m 00s |
| 03-TimeTravel.sql | 40s | 1m 40s |
| Presenter narration | 20s | 2m 00s |

**Total: ~2-3 minutes**
*(can be trimmed to 2 minutes with fast execution and focused narration)*

## Mapping to Slide Concepts

| Demo Component | Slide Concept |
|----------------|---------------|
| Employee table creation | Temporal table syntax, PERIOD FOR SYSTEM_TIME |
| HIDDEN columns | Reducing visual noise, opt-in visibility |
| 02-Observe.sql UPDATE | Automatic history capture, no triggers needed |
| 02-Observe.sql DELETE | History preservation, nothing is lost |
| 03-TimeTravel.sql AS OF | Point-in-time queries, "state on date X" |
| 03-TimeTravel.sql BETWEEN | Range queries, auditing use case |
| 03-TimeTravel.sql ALL | Complete audit trail, regulatory compliance |

## Presenter Notes

### Before the Demo

1. **Test the connection**: Ensure SSMS connects to the Azure SQL database
2. **Verify setup**: Run `01-Setup.sql` once before presenting to ensure it works
3. **Open all 3 scripts**: Have them ready in separate SSMS tabs
4. **Set SSMS options**:
   - Enable "Results to Grid" (Ctrl+D)
   - Increase font size for projector visibility (Zoom: Ctrl+Scroll)

### During the Demo

**Script 1 (Setup):**
- Execute all at once (F5)
- While it runs: "I'm creating an Employee table with temporal tracking enabled"
- Point out the 4 employees and 3 history rows in the results

**Script 2 (Observe):**
- Execute section by section (highlight + F5)
- After UPDATE: "See how Alice's old $75k salary is now in history?"
- After DELETE: "David is gone from the current table, but his history is preserved"

**Script 3 (Time Travel):**
- Execute each query separately (highlight + F5)
- AS OF: "April 1st was before Alice's promotion — she's still a Developer here"
- BETWEEN: "Everyone who was employed during H1 2024"
- ALL: "The complete story — watch each employee's career progression"

### After the Demo

**Expected audience questions:**

**Q: "What about performance?"**
**A:** "History tables can grow large, but they support standard indexes and partitioning. SQL Server optimizes queries to only hit the history table when needed via FOR SYSTEM_TIME."

**Q: "Can I modify history?"**
**A:** "Not while versioning is on. You'd have to turn off SYSTEM_VERSIONING, make changes, and turn it back on. Generally not recommended — defeats the audit purpose."

**Q: "What if I need to purge old history?"**
**A:** "Use retention policies (ALTER TABLE ... SET SYSTEM_VERSIONING ... HISTORY_RETENTION_PERIOD = X DAYS). SQL Server automatically cleans up old rows."

**Q: "Does this work with all editions?"**
**A:** "SQL Server 2016+ (Standard, Enterprise) and Azure SQL Database. Not in Express edition."

**Q: "What about storage costs?"**
**A:** "History tables use the same storage as regular tables. You can use columnstore indexes on history for better compression. Azure SQL charges by database size, so plan retention accordingly."

## Why Employee Domain?

**Alternative domains considered:**
- **Product Pricing**: Good for e-commerce, but less relatable to DBAs
- **Inventory**: Too abstract (quantity changes less compelling than human stories)
- **Orders**: Too complex (requires multiple tables)

**Why Employee wins:**
- **Human narrative**: Promotions, raises, departures are easy to follow
- **Relatable to audience**: Developers/DBAs understand HR scenarios
- **Clear audit use case**: "Who was in what role on date X?" is a common compliance question
- **Multiple change types**: Title changes, salary adjustments, terminations all tell different stories

## Troubleshooting

### Issue: Queries return no results

**Cause**: Hardcoded timestamps don't match actual data timestamps

**Fix**: Verify the pre-seeded history was inserted correctly:
```sql
SELECT * FROM dbo.Employee_History ORDER BY EmployeeId, ValidFrom;
```

Check ValidFrom/ValidTo match the timestamps in `03-TimeTravel.sql`.

### Issue: "Database 'TemporalDemo' does not exist"

**Cause**: Terraform provisioning incomplete or SSMS connected to master database

**Fix**:
1. Verify Terraform output: `terraform output database_name`
2. In SSMS, manually select database from dropdown: `TemporalDemo`
3. Or add `USE TemporalDemo; GO` at top of script (already included)

### Issue: ValidFrom/ValidTo not showing in results

**Cause**: They're HIDDEN columns

**Fix**: This is expected! SELECT * won't show them. To see them:
```sql
SELECT EmployeeId, EmployeeName, JobTitle, Salary, ValidFrom, ValidTo
  FROM dbo.Employee;
```

### Issue: WAITFOR DELAY takes too long

**Cause**: Demo environments may have latency

**Fix**: Reduce or remove delays in `02-Observe.sql`:
```sql
-- WAITFOR DELAY '00:00:02';  -- Comment out if running slow
```

Note: This may result in identical ValidFrom timestamps for some operations.

## Cleanup

### Option 1: Keep Infrastructure, Reset Data

Run the cleanup block at the end of `03-TimeTravel.sql`:
```sql
ALTER TABLE dbo.Employee SET (SYSTEM_VERSIONING = OFF);
DROP TABLE IF EXISTS dbo.Employee_History;
DROP TABLE IF EXISTS dbo.Employee;
```

Then re-run `01-Setup.sql` to start fresh.

### Option 2: Destroy Everything (Terraform)

```bash
cd ../FastSetup/terraform
terraform destroy
```

Type `yes` to confirm. This deletes all Azure resources.

## Additional Resources

- **SQL Server Temporal Tables Docs**: https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables
- **Azure SQL Pricing**: https://azure.microsoft.com/en-us/pricing/details/sql-database/
- **SSMS Download**: https://aka.ms/ssms
- **Original SQLDemo**: See `../SQLDemo/` for the comprehensive 15-script version

---

**Demo created by:** Marty (SQL Developer)  
**Last updated:** 2025-01-27  
**Presentation:** Time Travelling Data — SQL Server Temporal Tables
