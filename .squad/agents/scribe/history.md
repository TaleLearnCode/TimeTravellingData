# Scribe — History & Learnings

## Project Context
**Project:** Time Travelling Data — 20-minute conference presentation on SQL Server temporal tables
**User:** Chad Green

## Session: EF Core Demo Build (2026-03-02)

**Team:** Jennifer (EF Core dev) + Marty (Infrastructure) + Biff (Reviewer)

### Orchestration Summary
1. **Jennifer:** Built EFCoreDemoFast .NET 8 console app with all 5 temporal LINQ extensions
2. **Marty:** Added TemporalEFDemo database resource to Terraform (same server as Demo 1)
3. **Biff:** Reviewed and approved EFCoreDemoFast—high quality, demo-ready
4. **Scribe:** Wrote orchestration logs, session log, merged inbox decisions to decisions.md, updated agent history files

### Key Decisions Documented
- **Database Structure:** TemporalEFDemo separate from TemporalSQLDemo, same Azure SQL server
- **Domain Consistency:** Employee narrative identical to Demo 1 (Alice, Bob, Carol, David)
- **Temporal Extensions:** All 5 LINQ methods implemented with T-SQL equivalents in comments
- **DateTime Handling:** C# variables (seedTime, afterChanges) captured at runtime; no hardcoded timestamps
- **Architecture:** Shadow properties for period columns; POCO remains minimal

### Status
✅ Demo 2 approved and ready for Chad's presentation  
✅ All team updates documented in agent history files  
✅ Decisions merged and deduplicated  
✅ Ready for git commit

## Learnings
