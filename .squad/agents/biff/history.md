# Biff — History & Learnings

## Project Context
**Project:** Time Travelling Data — 20-minute conference presentation on SQL Server temporal tables
**Tech Stack:** SQL Server / Azure SQL, SSMS, T-SQL, .NET 8, Entity Framework Core 8
**User:** Chad Green

## Review Standards
- Demo 1 (SSMS): ~8 minutes max, covers create + DML + all FOR SYSTEM_TIME variants
- Demo 2 (EF Core): ~8 minutes max, covers migration + seed data + LINQ temporal queries
- Buffer: ~4 minutes for transitions and Q&A
- Both demos must run clean on Azure SQL

## Known Risks to Watch For
- Azure SQL permissions (temporal table DDL requires appropriate rights)
- EF Core connection string must point to Azure SQL
- WAITFOR DELAY may be needed between DML steps to create meaningful time gaps in history
- EF Core temporal queries return DateTime values in UTC

## Learnings

### 2025-01-27: SQLDemoFast Review — Comment Accuracy Is Critical

**What I Reviewed:** Marty's 3-script SQL temporal tables demo with pre-seeded history approach

**Key Finding:** Expected results comments MUST match actual query behavior. Found a critical mismatch where:
- Script said "Expected: 2 employees" for AS OF '2024-04-01' query
- Actual result: 3 employees (Alice, Bob, **Carol**)
- Carol's Intern record (ValidFrom 2024-03-01, ValidTo 2024-06-15) overlaps April 1st timestamp
- Would confuse audience when presenter says one thing, SQL returns another

**Lesson Learned:** When reviewing demos with temporal queries, ALWAYS:
1. Manually trace each pre-seeded history row's ValidFrom/ValidTo range
2. Verify the query timestamp falls within/outside those ranges as expected
3. Check that comment-stated row counts match actual query logic
4. Don't just skim comments — validate them against the data

**Secondary Finding:** Vague comments like "Alice's old salary" are confusing when Alice has MULTIPLE salary versions. Be specific: "Alice's $75k Senior Developer row" vs "Alice's $65k Developer row."

**What Worked Well in Marty's Demo:**
- Pre-seeded history technique (turning off SYSTEM_VERSIONING, inserting history, turning back on) is elegant
- Employee domain is more compelling than Product Pricing for developer audiences (promotions > price changes)
- Terraform config was solid — no issues found
- README was comprehensive with timing guide, troubleshooting, presenter notes

**Process Note:** Marty deviated from Doc's Product Pricing domain without approval. While the change was arguably better, it's a process violation. Team members should consult leads before changing specs.

### 2025-01-27: SQLDemoFast Re-Review — All Fixes Applied Successfully

**What I Re-Reviewed:** Doc's fixes to SQLDemoFast after my initial rejection

**Result:** ✅ **APPROVED** — All 4 must-pass checks passed, both bonus checks completed

**What Doc Fixed:**
1. ✅ 03-TimeTravel.sql line 30: Changed "2 employees" → "3 employees" and added Carol to expected results
2. ✅ README.md line 92: Changed "2 rows" → "3 rows" and mentioned Carol (Intern $35k)
3. ✅ 02-Observe.sql line 132: Changed vague "Alice's old salary" → specific "Alice's $75k Senior Developer row"
4. ✅ Domain issue: Coordinator confirmed Employee domain was Doc's architectural decision, not Marty's deviation
5. ✅ BONUS: README.md line 107: Updated timing to "~2-3 minutes" (realistic vs optimistic)

**Lesson Learned:** When someone applies fixes to previously rejected work:
1. Re-read my original review to refresh on EXACTLY what I flagged
2. Check EACH specific fix location (line numbers matter!)
3. Verify the fix matches my recommended solution (not just "close enough")
4. Don't re-test things that weren't issues (e.g., temporal table logic that already worked)
5. Document what changed vs what was already correct

**Key Insight:** Doc's fixes were **surgical and precise** — they changed only what was broken, didn't refactor unnecessarily. Every fix matched my recommended solution exactly. This is ideal remediation.

**Process Win:** The coordinator clarified that the Employee domain choice was actually Doc's decision as team lead, not a rogue deviation by Marty. This saved needless refactoring back to Product Pricing. Good escalation practice.

### 2026-03-02: EFCoreDemoFast Review — APPROVED ✅

**What I Reviewed:** Jennifer's .NET 8 EF Core demo project (`Demos/EFCoreDemoFast`) for correctness, demo quality, and readiness.

**Review Verdict:** ✅ **APPROVED** — High-quality, correct, demo-ready.

**Key Findings:**
- ✅ **Correctness:** Temporal configuration (`IsTemporal()`) correctly maps to migration and history table
- ✅ **Idempotency:** `ExecuteDeleteAsync()` + `MigrateAsync()` ensure repeatable runs
- ✅ **Timing:** seedTime captured after SaveChangesAsync; 3-second delay ensures safe TemporalAsOf query window
- ✅ **Temporal Queries:** All 5 extensions (TemporalAll, TemporalAsOf, TemporalBetween, TemporalFromTo, TemporalContainedIn) correctly implemented
- ✅ **Demo Quality:** Console output formatting is audience-friendly; code comments link EF Core LINQ to Demo 1's T-SQL equivalents; runtime ~7–10 seconds
- ✅ **Configuration:** Targets .NET 8; EF Core 8 SQL Server package correct; secrets properly gitignored with appsettings.example.json template

**Minor Suggestion (Non-Blocking):** TemporalBetween and TemporalFromTo may return identical results due to "safe" timestamp boundaries outside transaction windows. Acceptable for the demo—showcasing both API methods is valuable for audience.

**Status:** Ready for Chad to present.

**Process Note:** This demo demonstrates excellent complementarity with Demo 1 (SQL)—same Employee domain narrative, both leverage Azure SQL temporal tables, all query patterns mapped between T-SQL and EF Core LINQ.
