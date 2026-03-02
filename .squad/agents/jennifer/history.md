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
