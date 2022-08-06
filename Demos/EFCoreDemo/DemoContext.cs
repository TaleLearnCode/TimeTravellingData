using Microsoft.EntityFrameworkCore;

namespace EFCoreDemo;

public class DemoContext : DbContext
{

	protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
	{
		optionsBuilder.UseSqlServer("Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=TTD_EFCore;Integrated Security=True");
	}

	public DbSet<Employee> Employees { get; set; }

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.Entity<Employee>().ToTable("Employee", e => e.IsTemporal());
	}

}