# Demo 2 — EF Core Temporal Tables (EFCoreDemoFast)

> **Presentation:** Time Travelling Data — ~2 minutes  
> **Audience:** Already knows what temporal tables are (from Demo 1 — SQLDemoFast).  
> **Goal:** Show how EF Core makes temporal tables *natural* for C# developers.

---

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8)
- Azure SQL database **TemporalEFDemo** provisioned (same server as Demo 1 — different database)
  - The database must exist; the migration creates the `Employees` table and `EmployeesHistory` table automatically
- `appsettings.json` updated with your actual connection string (see Setup below)

---

## Pre-Demo Setup

### 1. Update connection string

Copy the example file and fill in your server + credentials:

```bash
# already done if appsettings.json has your values
cp appsettings.example.json appsettings.json
# edit appsettings.json — replace YOUR-SERVER and YOUR-PASSWORD
```

### 2. Restore packages

```bash
dotnet restore
```

### 3. (Optional) Apply migration only

```bash
dotnet ef database update
```

### 4. Run the demo

```bash
dotnet run
```

`dotnet run` applies migrations automatically (idempotent) and then executes the full demo flow. You can run it multiple times — it clears and re-seeds each time.

---

## Demo Script (~2 minutes)

### Opening (15 s)
> "Demo 1 was raw T-SQL. Now let's see the same concepts through the lens of a C# developer using Entity Framework Core 8."

### Step 1 — Show the .csproj (15 s)
> "No special packages. Just the standard EF Core SQL Server provider. That's it."

Point to: `EFCoreDemoFast.csproj`
- `Microsoft.EntityFrameworkCore.SqlServer` — that's the only runtime package needed

### Step 2 — Show the model (15 s)
> "Notice: no ValidFrom, no ValidTo, no period columns on the POCO. EF manages those as shadow properties."

Point to: `Models/Employee.cs`

### Step 3 — Show the DbContext (20 s)
> "Here's the magic line."

Point to: `Data/TemporalContext.cs` — specifically `entity.ToTable(tb => tb.IsTemporal())`

> "One line of fluent configuration tells EF: make this a system-versioned temporal table. EF generates the history table, the period columns, the SQL Server `WITH (SYSTEM_VERSIONING = ON)` — all of it."

### Step 4 — Show the migration (20 s)
> "When we ran `dotnet ef migrations add`, EF generated this migration. Notice the SqlServer:IsTemporal annotation and the PeriodStart/PeriodEnd columns. EF translates this to the correct T-SQL CREATE TABLE statement with SYSTEM_VERSIONING."

Point to: `Migrations/20240101000000_InitialCreate.cs`

### Step 5 — Run the demo (30 s)
> "Program.cs captures C# DateTimes — no hardcoded SQL timestamps. Let's run it."

```bash
dotnet run
```

Walk through console output:
1. Migrations applied, data seeded
2. 3-second wait (time separation)
3. Alice promoted, David deleted
4. **Temporal queries** — each line maps to the FOR SYSTEM_TIME variant from Demo 1:
   - `TemporalAll()` → `FOR SYSTEM_TIME ALL`
   - `TemporalAsOf(seedTime + 1s)` → `FOR SYSTEM_TIME AS OF`
   - `TemporalBetween(...)` → `FOR SYSTEM_TIME BETWEEN`
   - `TemporalFromTo(...)` → `FOR SYSTEM_TIME FROM ... TO`
   - `TemporalContainedIn(...)` → `FOR SYSTEM_TIME CONTAINED IN`

> "David's row shows up in TemporalContainedIn — born and deleted entirely within our demo window. EF found him in the history table."

**Total: ~2 minutes**

---

## Expected Output (approximate)

```
══════════════════════════════════════════════════════════════
  TIME TRAVELLING DATA — EF Core Temporal Tables Demo
══════════════════════════════════════════════════════════════

Applying migrations...
Clearing existing data...

Seeding employees...
  seedTime captured: 2024-01-01 00:00:05Z

── Current State (after seed) ──────────────────────────────
  Name                 Title                      Salary       Dept
  -------------------- -------------------------- ----------   ------------
  Alice Hart           Developer                   $65,000     Engineering
  Bob Chen             Senior Project Manager     $110,000     Product
  Carol Reyes          Intern                      $35,000     Engineering
  David Kim            Data Analyst                $65,000     Analytics

⏳ Waiting 3 seconds before making changes...

Making changes:
  • Promoting Alice Hart  → Senior Developer, $80,000
  • Terminating David Kim (delete)
  afterChanges captured: 2024-01-01 00:00:08Z

── Current State (after changes) ────────────────────────────
  Alice Hart           Senior Developer            $80,000     Engineering
  Bob Chen             Senior Project Manager     $110,000     Product
  Carol Reyes          Intern                      $35,000     Engineering

══════════════════════════════════════════════════════════════
  TEMPORAL QUERIES
══════════════════════════════════════════════════════════════

── A) TemporalAll()  →  FOR SYSTEM_TIME ALL ─────────────────
     Every row ever stored — current + all history
  Alice Hart   Developer          $65,000  2024-01-01 00:00:05Z  2024-01-01 00:00:08Z
  Alice Hart   Senior Developer   $80,000  2024-01-01 00:00:08Z  ∞ (current)
  Bob Chen     Senior PM         $110,000  2024-01-01 00:00:05Z  ∞ (current)
  Carol Reyes  Intern             $35,000  2024-01-01 00:00:05Z  ∞ (current)
  David Kim    Data Analyst       $65,000  2024-01-01 00:00:05Z  2024-01-01 00:00:08Z

── B) TemporalAsOf(seedTime + 1s)  →  FOR SYSTEM_TIME AS OF ─
  Alice Hart           Developer          $65,000
  Bob Chen             Senior PM         $110,000
  Carol Reyes          Intern             $35,000
  David Kim            Data Analyst       $65,000

... (C, D, E follow similar pattern)
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `Cannot open server` | Check Azure SQL firewall — add your IP |
| `Login failed` | Verify User ID and Password in appsettings.json |
| `Database TemporalEFDemo not found` | Create the database in Azure Portal (empty DB is fine, migration creates tables) |
| `Already applied migration` | Safe — `MigrateAsync()` is idempotent |
| No rows in TemporalContainedIn | Ensure `seedTime.AddSeconds(-1)` is before David's PeriodStart; the 3-second wait helps ensure separation |

---

## File Structure

```
EFCoreDemoFast/
├── EFCoreDemoFast.csproj          # .NET 8 project — standard EF Core SQL Server only
├── Program.cs                     # ← MAIN DEMO FILE — the full demo flow
├── appsettings.json               # Connection string (gitignored — contains secrets)
├── appsettings.example.json       # Safe placeholder version for source control
├── .gitignore
├── Models/
│   └── Employee.cs                # Simple POCO — no period columns
├── Data/
│   └── TemporalContext.cs         # DbContext with IsTemporal() config
└── Migrations/
    ├── 20240101000000_InitialCreate.cs    # Migration that creates temporal table
    └── TemporalContextModelSnapshot.cs   # EF model snapshot
```
