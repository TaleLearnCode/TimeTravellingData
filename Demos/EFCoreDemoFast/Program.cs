using EFCoreDemoFast.Data;
using EFCoreDemoFast.Models;
using Microsoft.EntityFrameworkCore;

// ══════════════════════════════════════════════════════════════════
//   TIME TRAVELLING DATA — EF Core Demo (Demo 2 of 2)
//   Shows EF Core 8 temporal table support against Azure SQL
// ══════════════════════════════════════════════════════════════════

Console.WriteLine("══════════════════════════════════════════════════════════════");
Console.WriteLine("  TIME TRAVELLING DATA — EF Core Temporal Tables Demo");
Console.WriteLine("══════════════════════════════════════════════════════════════");
Console.WriteLine();

// ── SETUP ────────────────────────────────────────────────────────
// Apply migrations (idempotent — safe to run repeatedly)
// This creates the Employees table WITH system versioning + EmployeesHistory table
using var context = new TemporalContext();
Console.WriteLine("Applying migrations...");
await context.Database.MigrateAsync();

// Clear any existing data so each demo run starts fresh
Console.WriteLine("Clearing existing data...");
await context.Employees.ExecuteDeleteAsync();
Console.WriteLine();

// ── SEED ─────────────────────────────────────────────────────────
// Insert the four employees from our domain story
Console.WriteLine("Seeding employees...");
context.Employees.AddRange(
    new Employee { Name = "Alice Hart",  Title = "Developer",               Salary = 65_000, Department = "Engineering" },
    new Employee { Name = "Bob Chen",    Title = "Senior Project Manager",   Salary = 110_000, Department = "Product"    },
    new Employee { Name = "Carol Reyes", Title = "Intern",                   Salary = 35_000,  Department = "Engineering" },
    new Employee { Name = "David Kim",   Title = "Data Analyst",             Salary = 65_000,  Department = "Analytics"  }
);
await context.SaveChangesAsync();

// Capture this moment — we'll use it for temporal queries later
DateTime seedTime = DateTime.UtcNow;
Console.WriteLine($"  seedTime captured: {seedTime:u}");
Console.WriteLine();

// ── CURRENT STATE (after seed) ───────────────────────────────────
Console.WriteLine("── Current State (after seed) ──────────────────────────────");
var all = await context.Employees.OrderBy(e => e.Name).ToListAsync();
PrintEmployees(all);
Console.WriteLine();

// ── WAIT ─────────────────────────────────────────────────────────
// Give SQL Server time to advance the period start timestamps
Console.WriteLine("⏳ Waiting 3 seconds before making changes...");
await Task.Delay(3000);
Console.WriteLine();

// ── LIVE CHANGES ─────────────────────────────────────────────────
// Alice gets promoted; David is terminated
Console.WriteLine("Making changes:");
Console.WriteLine("  • Promoting Alice Hart  → Senior Developer, $80,000");
Console.WriteLine("  • Terminating David Kim (delete)");

var alice = await context.Employees.SingleAsync(e => e.Name == "Alice Hart");
alice.Title  = "Senior Developer";
alice.Salary = 80_000;

var david = await context.Employees.SingleAsync(e => e.Name == "David Kim");
context.Employees.Remove(david);

await context.SaveChangesAsync();

// Capture the moment after our changes
DateTime afterChanges = DateTime.UtcNow;
Console.WriteLine($"  afterChanges captured: {afterChanges:u}");
Console.WriteLine();

// ── CURRENT STATE (after changes) ────────────────────────────────
Console.WriteLine("── Current State (after changes) ────────────────────────────");
var current = await context.Employees.OrderBy(e => e.Name).ToListAsync();
PrintEmployees(current);
Console.WriteLine();

// Small buffer so all changes are visible in temporal queries
await Task.Delay(1000);

// ══════════════════════════════════════════════════════════════════
//   TEMPORAL QUERIES
//   Each maps to a T-SQL FOR SYSTEM_TIME variant from Demo 1
// ══════════════════════════════════════════════════════════════════
Console.WriteLine("══════════════════════════════════════════════════════════════");
Console.WriteLine("  TEMPORAL QUERIES");
Console.WriteLine("══════════════════════════════════════════════════════════════");
Console.WriteLine();

// ── Query A: TemporalAll ──────────────────────────────────────────
// LINQ:   context.Employees.TemporalAll()
// T-SQL:  SELECT * FROM Employees FOR SYSTEM_TIME ALL
Console.WriteLine("── A) TemporalAll()  →  FOR SYSTEM_TIME ALL ─────────────────");
Console.WriteLine("     Every row ever stored — current + all history");
var rowsAll = await context.Employees
    .TemporalAll()
    .OrderBy(e => e.Name)
    .ThenBy(e => EF.Property<DateTime>(e, "PeriodStart"))
    .Select(e => new {
        e.Id, e.Name, e.Title, e.Salary,
        PeriodStart = EF.Property<DateTime>(e, "PeriodStart"),
        PeriodEnd   = EF.Property<DateTime>(e, "PeriodEnd")
    })
    .ToListAsync();
PrintTemporalRows(rowsAll.Select(r => (r.Name, r.Title, r.Salary, r.PeriodStart, r.PeriodEnd)));
Console.WriteLine();

// ── Query B: TemporalAsOf ─────────────────────────────────────────
// LINQ:   context.Employees.TemporalAsOf(seedTime.AddSeconds(1))
// T-SQL:  SELECT * FROM Employees FOR SYSTEM_TIME AS OF @seedTime+1s
Console.WriteLine("── B) TemporalAsOf(seedTime + 1s)  →  FOR SYSTEM_TIME AS OF ─");
Console.WriteLine($"     What did we have right after seeding?  [{seedTime.AddSeconds(1):u}]");
var rowsAsOf = await context.Employees
    .TemporalAsOf(seedTime.AddSeconds(1))
    .OrderBy(e => e.Name)
    .ToListAsync();
PrintEmployees(rowsAsOf);
Console.WriteLine();

// ── Query C: TemporalBetween ──────────────────────────────────────
// LINQ:   context.Employees.TemporalBetween(seedTime, afterChanges)
// T-SQL:  SELECT * FROM Employees FOR SYSTEM_TIME BETWEEN @seed AND @after
Console.WriteLine("── C) TemporalBetween(seedTime, afterChanges)  →  FOR SYSTEM_TIME BETWEEN ─");
Console.WriteLine("     Rows whose period overlaps the demo window (inclusive start, exclusive end)");
var rowsBetween = await context.Employees
    .TemporalBetween(seedTime, afterChanges)
    .OrderBy(e => e.Name)
    .ThenBy(e => EF.Property<DateTime>(e, "PeriodStart"))
    .Select(e => new {
        e.Id, e.Name, e.Title, e.Salary,
        PeriodStart = EF.Property<DateTime>(e, "PeriodStart"),
        PeriodEnd   = EF.Property<DateTime>(e, "PeriodEnd")
    })
    .ToListAsync();
PrintTemporalRows(rowsBetween.Select(r => (r.Name, r.Title, r.Salary, r.PeriodStart, r.PeriodEnd)));
Console.WriteLine();

// ── Query D: TemporalFromTo ───────────────────────────────────────
// LINQ:   context.Employees.TemporalFromTo(seedTime, afterChanges)
// T-SQL:  SELECT * FROM Employees FOR SYSTEM_TIME FROM @seed TO @after
Console.WriteLine("── D) TemporalFromTo(seedTime, afterChanges)  →  FOR SYSTEM_TIME FROM ... TO ─");
Console.WriteLine("     Same window, both boundaries exclusive");
var rowsFromTo = await context.Employees
    .TemporalFromTo(seedTime, afterChanges)
    .OrderBy(e => e.Name)
    .ThenBy(e => EF.Property<DateTime>(e, "PeriodStart"))
    .Select(e => new {
        e.Id, e.Name, e.Title, e.Salary,
        PeriodStart = EF.Property<DateTime>(e, "PeriodStart"),
        PeriodEnd   = EF.Property<DateTime>(e, "PeriodEnd")
    })
    .ToListAsync();
PrintTemporalRows(rowsFromTo.Select(r => (r.Name, r.Title, r.Salary, r.PeriodStart, r.PeriodEnd)));
Console.WriteLine();

// ── Query E: TemporalContainedIn ──────────────────────────────────
// LINQ:   context.Employees.TemporalContainedIn(seedTime.AddSeconds(-1), afterChanges.AddSeconds(1))
// T-SQL:  SELECT * FROM Employees FOR SYSTEM_TIME CONTAINED IN (@start, @end)
Console.WriteLine("── E) TemporalContainedIn(seedTime - 1s, afterChanges + 1s)  →  FOR SYSTEM_TIME CONTAINED IN ─");
Console.WriteLine("     Rows whose ENTIRE lifespan falls within the window");
Console.WriteLine("     (David's row: born at seed, ended at delete — fully contained)");
var rowsContained = await context.Employees
    .TemporalContainedIn(seedTime.AddSeconds(-1), afterChanges.AddSeconds(1))
    .OrderBy(e => e.Name)
    .ThenBy(e => EF.Property<DateTime>(e, "PeriodStart"))
    .Select(e => new {
        e.Id, e.Name, e.Title, e.Salary,
        PeriodStart = EF.Property<DateTime>(e, "PeriodStart"),
        PeriodEnd   = EF.Property<DateTime>(e, "PeriodEnd")
    })
    .ToListAsync();
PrintTemporalRows(rowsContained.Select(r => (r.Name, r.Title, r.Salary, r.PeriodStart, r.PeriodEnd)));
Console.WriteLine();

Console.WriteLine("══════════════════════════════════════════════════════════════");
Console.WriteLine("  Demo complete.");
Console.WriteLine("══════════════════════════════════════════════════════════════");

// ── Helpers ───────────────────────────────────────────────────────

static void PrintEmployees(IEnumerable<Employee> employees)
{
    Console.WriteLine($"  {"Name",-20} {"Title",-26} {"Salary",10}  {"Dept",-12}");
    Console.WriteLine($"  {new string('-', 20)} {new string('-', 26)} {new string('-', 10)}  {new string('-', 12)}");
    foreach (var e in employees)
        Console.WriteLine($"  {e.Name,-20} {e.Title,-26} {e.Salary,10:C0}  {e.Department,-12}");
}

static void PrintTemporalRows(IEnumerable<(string Name, string Title, decimal Salary, DateTime PeriodStart, DateTime PeriodEnd)> rows)
{
    Console.WriteLine($"  {"Name",-20} {"Title",-26} {"Salary",10}  {"PeriodStart (UTC)",-22}  {"PeriodEnd (UTC)",-22}");
    Console.WriteLine($"  {new string('-', 20)} {new string('-', 26)} {new string('-', 10)}  {new string('-', 22)}  {new string('-', 22)}");
    foreach (var r in rows)
    {
        var end = r.PeriodEnd == DateTime.MaxValue ? "∞ (current)" : r.PeriodEnd.ToString("u");
        Console.WriteLine($"  {r.Name,-20} {r.Title,-26} {r.Salary,10:C0}  {r.PeriodStart,-22:u}  {end,-22}");
    }
}
