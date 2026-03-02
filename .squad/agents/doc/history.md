# Doc — History & Learnings

## Project Context
**Project:** Time Travelling Data — 20-minute conference presentation on SQL Server temporal tables
**Tech Stack:** SQL Server / Azure SQL, SSMS, T-SQL, .NET 8, Entity Framework Core 6+
**User:** Chad Green

## Presentation Structure
- Demo 1: Azure SQL + SSMS — create temporal table, run DML, observe history, run FOR SYSTEM_TIME queries
- Demo 2: EF Core — project setup, migration, LINQ temporal queries (TemporalAsOf, TemporalAll, etc.)
- Total presentation: 20 minutes — demos must be tight and quick

## Slides Summary
1. What Are Temporal Tables — Rule of Two, ValidFrom/ValidTo, system-versioned
2. Why Use Them — immutable history, built-in querying, low maintenance
3. Use Cases — auditing, state reconstruction, trends, SCD, accidental recovery
4. How They Work — insert/update/delete lifecycle, FOR SYSTEM_TIME variants
5. EF Core 6+ support — migrations, LINQ extensions
6. Hands-On demos

## Learnings

### 2025-01-24 — SQL Demo Fast Design
**Task:** Design streamlined 2-minute SQL demo to replace 15-script original demo.

**Key Decisions:**
- **Domain:** Product Pricing (simple, relatable, visual price changes)
- **Query Coverage:** AS OF, BETWEEN, ALL (cut FROM/TO and CONTAINED IN for time)
- **Pre-populated History:** Turn off versioning → insert history rows with hardcoded 2024 timestamps → re-enable versioning. Solves the "empty results from hardcoded timestamp queries" problem.
- **Structure:** 3 scripts (Setup, Observe, TimeTravel) in new `SQLDemoFast/` folder
- **Terraform Scope:** Azure SQL Server, Database, Firewall Rules, Resource Group

**What Worked:**
- Analyzing existing demo (15 scripts across 3 folders) revealed complexity bloat
- Identified root cause: queries used 2022 timestamps that don't match fresh inserts
- Chad's proposed solution (disable versioning, seed history, re-enable) is correct approach
- Product Pricing domain is cleaner than Employees (sensitive) or Inventory (already used)

**Risks Flagged:**
- Timing: even 2 minutes requires tight narration — presenter must rehearse
- Terraform: firewall rules need presenter's IP (unknown until day-of)
- History seeding: Marty must test that re-enabled versioning still works correctly after manual inserts

**Deliverables:**
- Plan document: `.squad/decisions/inbox/doc-sql-demo-fast-plan.md`
- Ready for Marty to implement scripts + Terraform

**Next Phase:** Await Marty's implementation, then review for timing/complexity before handoff to Chad.
