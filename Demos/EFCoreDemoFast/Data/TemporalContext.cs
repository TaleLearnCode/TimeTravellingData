using EFCoreDemoFast.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace EFCoreDemoFast.Data;

public class TemporalContext : DbContext
{
    public DbSet<Employee> Employees => Set<Employee>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        var config = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json", optional: false)
            .AddEnvironmentVariables()
            .Build();

        optionsBuilder.UseSqlServer(config.GetConnectionString("DefaultConnection"));
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Employee>(entity =>
        {
            entity.Property(e => e.Name).HasMaxLength(100);
            entity.Property(e => e.Title).HasMaxLength(100);
            entity.Property(e => e.Salary).HasColumnType("decimal(10,2)");
            entity.Property(e => e.Department).HasMaxLength(100);

            // ── This is the magic line ──────────────────────────────────────
            // Tells EF Core to create this as a system-versioned temporal table.
            // EF automatically creates the history table and period columns.
            entity.ToTable(tb => tb.IsTemporal());
        });
    }
}
