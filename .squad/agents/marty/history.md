# Marty — History & Learnings

## Project Context
**Project:** Time Travelling Data — 20-minute conference presentation on SQL Server temporal tables
**Tech Stack:** SQL Server / Azure SQL, SSMS, T-SQL
**User:** Chad Green

## Demo 1 Scope
Create a focused SSMS demo that:
1. Creates a temporal table (with history table)
2. Runs INSERT/UPDATE/DELETE to build up history
3. Queries history using all FOR SYSTEM_TIME variants
4. Runs in Azure SQL
5. Fits in ~8 minutes of presentation time

## FOR SYSTEM_TIME Variants to Cover
- AS OF — point-in-time snapshot
- FROM … TO — exclusive range
- BETWEEN … AND — inclusive range
- CONTAINED IN — fully within range
- ALL — entire history including current

## Slide Reference
- Slide: "SELECT * FROM DemoTable FOR SYSTEM_TIME BETWEEN '2022-08-05' AND '2022-08-06' WHERE Id = 123 ORDER BY ValidFrom"
- ValidFrom / ValidTo columns are system-managed
- History table stores all previous versions

## Learnings

### 2025-01-27: Analyzed Existing SQL Demo Scripts
**Task:** Reviewed all 14 .sql files in Demos\SQLDemo\ to inform new demo design

**Key Findings:**
- Existing demos use 3 different domains (Department, CompanyLocation, Inventory) — creates fragmentation
- CRITICAL ISSUE: Hardcoded 2022 timestamps in query scripts won't work today
- 14 files is too many for 8-minute demo; need to focus on core concepts only
- Best patterns identified: HIDDEN period columns, WAITFOR DELAY for building history, comprehensive FOR SYSTEM_TIME coverage
- HIDDEN period syntax keeps demo output clean: `ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL`
- WAITFOR DELAY (2 seconds, used 2x = 4 seconds total) is acceptable for live demos

**Recommendations Made:**
- Use single domain throughout: Product (price tracking) or Employee (promotions/salary)
- Create 3-script structure: Setup → Build History → Query History
- Hybrid timestamp approach: WAITFOR DELAY + copy actual timestamps from output for precise queries
- Keep scripts under 8 minutes total with presenter narration during delays

**Decision Point for Team:**
- Domain choice: Product vs Employee vs Inventory
- Timestamp strategy: Hybrid (WAITFOR + copy) vs fully dynamic
- Scope: Core 3 scripts vs optional 4th advanced script

**Analysis Written To:** `.squad/decisions/inbox/marty-existing-demo-analysis.md`

### 2025-01-27: Built SQLDemoFast — Complete 2-Minute SQL Temporal Demo
**Task:** Implemented Doc's fast demo plan with Employee domain, pre-seeded history, and 3-script structure

**Files Created:**
1. `01-Setup.sql` — Creates Employee temporal table, inserts 4 current employees, pre-seeds history with hardcoded timestamps
2. `02-Observe.sql` — Live DML (UPDATE Alice's salary, DELETE David), shows history accumulating with WAITFOR DELAY
3. `03-TimeTravel.sql` — Time-travel queries (AS OF, BETWEEN, ALL) using pre-seeded timestamps
4. Terraform infrastructure (main.tf, variables.tf, outputs.tf, terraform.tfvars.example)
5. Complete documentation (2 README files: demo guide + Terraform deployment)

**Key Design Decisions:**
- **Domain: Employee** (per Doc's plan) — More compelling for DBA/developer audience than Product pricing
  - Schema: EmployeeId, EmployeeName, JobTitle, Department, Salary
  - Story: Alice (Developer → Senior Developer), Bob (Senior PM → Product Manager), Carol (Intern → Junior Developer), David (hired then deleted)
- **Hybrid History Strategy**: Pre-seeded history (for reliable query demos) + live DML (for "wow factor")
  - Pre-seed technique: Turn off versioning, INSERT into history table with hardcoded timestamps, turn versioning back on
  - Hardcoded timestamps: 2024-01-15, 2024-04-01, 2024-06-15, 2024-07-01, 2024-09-01
- **Query Coverage**: AS OF, BETWEEN, ALL (skipped FROM...TO and CONTAINED IN per Doc's plan — too nuanced for 2-minute demo)
- **WAITFOR DELAY**: 2 seconds × 2 = 4 seconds total (acceptable for live demo, creates temporal separation)
- **HIDDEN Period Columns**: ValidFrom/ValidTo not shown in SELECT * (cleaner presenter output)

**T-SQL Techniques Applied:**
- System versioning on/off toggle for manual history manipulation
- Explicit column lists when inserting into history table (ValidFrom/ValidTo required)
- GO separators for batch control in SSMS
- Comments written at presentation-quality (audience will read them on projector)

**Terraform Configuration:**
- Azure SQL Server (version 12.0) with globally unique naming
- Database: TemporalDemo, SKU S0 (affordable for demos)
- Firewall rules: Azure services + presenter IP
- Variables validated (IP format, password complexity, server name constraints)
- Outputs: FQDN, connection string (sensitive), SSMS connection info

**Azure SQL Compatibility Notes:**
- CREATE DATABASE is provisioned by Terraform (not in script)
- Scripts use `USE TemporalDemo` to connect
- All temporal table syntax identical to on-prem SQL Server 2016+
- UTC timestamps (added note in comments)

**Documentation Quality:**
- README.md: Complete presenter guide with timing, talking points, troubleshooting, Q&A prep
- terraform/README.md: Step-by-step deployment with error handling and security notes
- Inline SQL comments: Explain WHY not just WHAT (presentation-ready)
- Mapped demo sections to slide concepts for alignment

**Timing:**
- 01-Setup.sql: ~20 seconds
- 02-Observe.sql: ~40 seconds (includes 4 seconds WAITFOR)
- 03-TimeTravel.sql: ~40 seconds
- Total: ~2 minutes with narration

**Learnings:**
- **Pre-seeding history is essential** for demos with time-travel queries — removes dependency on "copy timestamp from previous run"
- **Employee domain > Product domain** for this audience — human stories (promotions, departures) more compelling than price changes
- **HIDDEN columns are critical** for presenter experience — keeps output clean without manually excluding ValidFrom/ValidTo
- **Hybrid approach works best**: Pre-seed for reliable queries, live DML for audience engagement
- **Comments matter in live demos**: These aren't just code comments, they're presenter notes and audience reading material

**Decisions Written To:** `.squad/decisions/inbox/marty-sqldemofast-decisions.md`

## TemporalEFDemo Database Resource — Terraform Update

**Date:** 2026-03-02  
**Task:** Add TemporalEFDemo database to Terraform for Demo 2 (EF Core)

### Changes Made
- **main.tf:** Added `azurerm_mssql_database` resource for TemporalEFDemo
  - Same Azure SQL Server as TemporalSQLDemo (Demo 1)
  - Consistent SKU and configuration
  - Follows naming and variable conventions
- **outputs.tf:** Added `temporal_ef_demo_db_name` and `temporal_ef_demo_connection_string` outputs

### Verification
✅ Terraform configuration valid  
✅ Database resource correctly integrated with existing server infrastructure  
✅ Connection strings available for Jennifer's EF Core app configuration

### Architecture Note
Same-server strategy confirmed by Chad—both Demo 1 (SQL) and Demo 2 (EF Core) run independently on single Azure SQL server with separate databases (TemporalSQLDemo and TemporalEFDemo).
