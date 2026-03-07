# Copilot Instructions — Time Travelling Data

This is a conference presentation repository for a session on **SQL Server Temporal Tables**. It contains two parallel demo tracks (T-SQL and EF Core), each in two variants (full and "fast" for 2-minute conference delivery).

## Repository Layout

```
Demos/
  SQLDemo/          # Full T-SQL demo — 15 numbered .sql scripts run in SSMS
  SQLDemoFast/      # 2-minute T-SQL demo — 3 scripts (01-Setup, 02-Observe, 03-TimeTravel)
  EFCoreDemo/       # Full EF Core demo — .NET 6 console app, LocalDB
  EFCoreDemoFast/   # 2-minute EF Core demo — .NET 10 console app, Azure SQL
  FastSetup/        # Shared Terraform for provisioning Azure SQL Server + both databases
Presentations/      # PDF slide decks from past events
Resources/          # Supporting materials
```

## Building and Running

### EFCoreDemoFast (.NET 10 — current "fast" demo)

```bash
cd Demos/EFCoreDemoFast
dotnet restore
dotnet run
```

Before running, copy and configure the connection string:
```bash
cp appsettings.example.json appsettings.json
# Edit appsettings.json — set DefaultConnection to your Azure SQL connection string
```

The app drops and recreates the `Employees` temporal table on each run — safe to run repeatedly.

### EFCoreDemo (.NET 6 — full demo, LocalDB)

```bash
cd Demos/EFCoreDemo
dotnet ef database update   # Creates TTD_EFCore database on LocalDB
dotnet run
```

### SQLDemoFast

Run `01-Setup.sql`, `02-Observe.sql`, `03-TimeTravel.sql` in order in SSMS against the `TemporalDemo` database.

### SQLDemo (full)

Run the numbered scripts in order from within SSMS. Scripts are grouped in folders by topic.

### Infrastructure (Azure SQL)

```bash
cd Demos/FastSetup/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — add subscription ID, location, SQL password
terraform init
terraform apply
```

One `terraform apply` provisions the server and both databases (`TemporalDemo` for SQL demo, `TemporalEFDemo` for EF demo).

## Key Conventions

### Two parallel tracks, same domain

Both the SQL and EF Core demos use an **Employee** domain (name, title, salary, department) on purpose — the narrative maps directly between the T-SQL `FOR SYSTEM_TIME` clauses and EF Core's `TemporalAll()` / `TemporalAsOf()` / `TemporalBetween()` / etc. Keep the domains in sync when updating demos.

### EF Core temporal configuration

Temporal tables are enabled with a single fluent API call — no period columns on the POCO:

```csharp
entity.ToTable(tb => tb.IsTemporal());
```

EF manages `PeriodStart`/`PeriodEnd` as **shadow properties**. Access them via:
```csharp
EF.Property<DateTime>(emp, "PeriodStart")
```

### EFCoreDemoFast resets on every run

`Program.cs` drops and recreates the `Employees` table via raw SQL before seeding. This is intentional for reliable demo resets. The `Migrations/` folder is reference material showing what EF generates — it is not used at runtime in the fast demo.

### EFCoreDemo (full) uses EF migrations

The full demo uses `dotnet ef database update` against `(localdb)\MSSQLLocalDB`, database `TTD_EFCore`. The migration is in `Demos/EFCoreDemo/Migrations/`.

### SQL demo uses HIDDEN period columns

In the SQL demo, `ValidFrom`/`ValidTo` are declared `HIDDEN` — they don't appear in `SELECT *`. To see them, name them explicitly:
```sql
SELECT EmployeeId, EmployeeName, ValidFrom, ValidTo FROM dbo.Employee;
```

### Connection strings are gitignored

`appsettings.json` in `EFCoreDemoFast/` is gitignored. The safe placeholder is `appsettings.example.json`. Never commit real connection strings.

### EF Core temporal query mapping

| EF Core method | T-SQL equivalent |
|----------------|-----------------|
| `TemporalAll()` | `FOR SYSTEM_TIME ALL` |
| `TemporalAsOf(dt)` | `FOR SYSTEM_TIME AS OF` |
| `TemporalBetween(start, end)` | `FOR SYSTEM_TIME BETWEEN` |
| `TemporalFromTo(start, end)` | `FOR SYSTEM_TIME FROM ... TO` |
| `TemporalContainedIn(start, end)` | `FOR SYSTEM_TIME CONTAINED IN` |
