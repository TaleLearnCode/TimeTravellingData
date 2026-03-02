# Jennifer — History & Learnings

## Project Context
**Project:** Time Travelling Data — 20-minute conference presentation on SQL Server temporal tables
**Tech Stack:** .NET 8, Entity Framework Core 8, Azure SQL
**User:** Chad Green

## Demo 2 Scope
Create a minimal EF Core demo that:
1. Defines a model with temporal table configuration (IsTemporal())
2. Creates and runs a migration that generates the temporal table + history table
3. Seeds some data with INSERTs, UPDATEs, DELETEs to build history
4. Runs LINQ queries using all temporal extensions
5. Connects to Azure SQL
6. Fits in ~8 minutes of presentation time

## EF Core Temporal LINQ Extensions
- TemporalAsOf(dateTime) — point-in-time snapshot
- TemporalAll() — all rows including history
- TemporalBetween(from, to) — rows valid in range (exclusive)
- TemporalFromTo(from, to) — rows valid in range
- TemporalContainedIn(from, to) — rows fully within range

## EF Core Fluent Config
```csharp
modelBuilder.Entity<MyEntity>().ToTable("MyTable", t => t.IsTemporal());
```

## Slide Reference
- EF Core temporal support added in EF Core 6.0
- Supports: creating tables via migrations, converting existing tables, querying history, restoring data

## Learnings

## EFCoreDemoFast — Completed

**Date:** 2026-03-02  
**Status:** ✅ Built and compiles successfully

### Key File Paths
- `Demos/EFCoreDemoFast/EFCoreDemoFast.csproj` — .NET 8 console app, EF Core 8 SQL Server
- `Demos/EFCoreDemoFast/Program.cs` — main demo flow with all 5 temporal queries
- `Demos/EFCoreDemoFast/Models/Employee.cs` — POCO, no period columns
- `Demos/EFCoreDemoFast/Data/TemporalContext.cs` — DbContext with `IsTemporal()` config
- `Demos/EFCoreDemoFast/Migrations/20240101000000_InitialCreate.cs` — temporal migration
- `Demos/EFCoreDemoFast/Migrations/TemporalContextModelSnapshot.cs` — EF model snapshot
- `Demos/EFCoreDemoFast/appsettings.json` — gitignored, holds real connection string
- `Demos/EFCoreDemoFast/appsettings.example.json` — safe placeholder for source control
- `Demos/EFCoreDemoFast/README.md` — presenter notes with 2-minute script

### Architecture Decisions
1. **No period columns on POCO** — EF manages PeriodStart/PeriodEnd as shadow properties; `EF.Property<DateTime>(e, "PeriodStart")` used in projections
2. **C# DateTime capture** — seedTime and afterChanges captured as C# variables, not hardcoded SQL timestamps; demonstrates natural C# developer workflow
3. **TemporalAsOf no-projection rule** — EF Core limitation: period columns not available in TemporalAsOf projections; only entity properties selected
4. **Manual migration file** — used fake timestamp `20240101000000` in filename; valid for EF migration ordering
5. **IsTemporal() fluent config** — single line in OnModelCreating; history table name defaults to `EmployeesHistory`
6. **MigrateAsync() at startup** — idempotent, allows `dotnet run` to self-setup
7. **ExecuteDeleteAsync() before seed** — ensures idempotent demo runs

### Patterns Used
- `entity.ToTable(tb => tb.IsTemporal())` — temporal table marker
- `EF.Property<DateTime>(e, "PeriodStart")` — shadow property access in LINQ
- `context.Employees.TemporalAll() / TemporalAsOf() / TemporalBetween() / TemporalFromTo() / TemporalContainedIn()` — all 5 temporal extensions demonstrated
- `await context.Database.MigrateAsync()` — apply migrations at startup

## EFCoreDemoFast — Biff Review Result

**Date:** 2026-03-02  
**Reviewer:** Biff  
**Status:** ✅ APPROVED

### Approval Feedback
- Temporal configuration and migration are correct
- Idempotency and timing logic are sound
- All 5 temporal LINQ extensions correctly demonstrate Azure SQL temporal table support
- Demo quality suitable for 8-minute conference presentation
- Code comments effectively bridge EF Core to Demo 1's T-SQL patterns

**Next Step:** Ready for Chad's presentation—Demo 2 (EF Core temporal) complements Demo 1 (SQL temporal) with identical Employee narrative across both platforms.
