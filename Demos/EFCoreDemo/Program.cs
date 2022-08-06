DateTime _updateDateTime = DateTime.UtcNow;

do
{
	await SwitchboardAsync();
	Console.WriteLine();
	Console.WriteLine();
	Console.ForegroundColor = ConsoleColor.Gray;
	Console.WriteLine("Press any [Enter] to finish demo...");
	Console.ReadLine();
	Console.ResetColor();
} while (true);


async Task SwitchboardAsync()
{
	Console.Clear();
	Console.ForegroundColor = ConsoleColor.Blue;
	Console.WriteLine(@"______________________ _________                        ________                         ");
	Console.WriteLine(@"\_   _____/\_   _____/ \_   ___ \  ___________   ____   \______ \   ____   _____   ____  ");
	Console.WriteLine(@" |    __)_  |    __)   /    \  \/ /  _ \_  __ \_/ __ \   |    |  \_/ __ \ /     \ /  _ \ ");
	Console.WriteLine(@" |        \ |     \    \     \___(  <_> )  | \/\  ___/   |    `   \  ___/|  Y Y  (  <_> )");
	Console.WriteLine(@"/_______  / \___  /     \______  /\____/|__|    \___  > /_______  /\___  >__|_|  /\____/ ");
	Console.WriteLine(@"        \/      \/             \/                   \/          \/     \/      \/        ");
	Console.ResetColor();
	Console.WriteLine();
	Console.WriteLine();
	Console.WriteLine("Select a demo option:");
	Console.WriteLine("\t[1] Initialize Database");
	Console.WriteLine("\t[2] Update Data");
	Console.WriteLine("\t[3] Delete Data");
	Console.WriteLine("\t[4] Get Data History");
	Console.WriteLine("\t[5] Data As Of Date");
	Console.WriteLine("\t[6] Restore Deleted Data");
	Console.WriteLine();
	bool validOptionSelected = false;
	do
	{
		switch (Console.ReadKey(true).Key)
		{
			case ConsoleKey.D1:
			case ConsoleKey.NumPad1:
				await InitializeDatabase();
				validOptionSelected = true;
				break;
			case ConsoleKey.D2:
			case ConsoleKey.NumPad2:
				await UpdateDepartmentAsync(6, "Legal");
				await UpdateDepartmentAsync(2, "IT");
				validOptionSelected = true;
				break;
			case ConsoleKey.D3:
			case ConsoleKey.NumPad3:
				await DeleteEmployeeAsync(6);
				validOptionSelected = true;
				break;
			case ConsoleKey.D4:
			case ConsoleKey.NumPad4:
				PrintEmployeeHistory(2);
				validOptionSelected = true;
				break;
			case ConsoleKey.D5:
			case ConsoleKey.NumPad5:
				await PrintEmployeeAsOfDateTimeAsync(2, _updateDateTime.Subtract(new TimeSpan(0, 0, 1)));
				validOptionSelected = true;
				break;
			case ConsoleKey.D6:
			case ConsoleKey.NumPad6:
				await RestoreDeletedEmployeeAsync(6);
				validOptionSelected = true;
				break;
		}
	} while (!validOptionSelected);
}

async Task InitializeDatabase()
{
	Console.WriteLine("Initializing database...");
	Employee graham = new() { FirstName = "Leanney", LastName = "Graham", Department = "HR" };
	Employee howell = new() { FirstName = "Ervint", LastName = "Howell", Department = "HR" };
	Employee baucho = new() { FirstName = "Clementine", LastName = "Baucho", Department = "Legal" };
	Employee lebsack = new() { FirstName = "Patriciari", LastName = "Lebsack", Department = "IT" };
	Employee dietrich = new() { FirstName = "Chelst", LastName = "Dietrich", Department = "IT" };
	Employee weissnat = new() { FirstName = "Kurt", LastName = "Weissnat", Department = "IT" };
	using DemoContext context = new();
	await context.AddRangeAsync(graham, howell, baucho, lebsack, dietrich, weissnat);
	context.SaveChanges();
	Console.WriteLine("Database initialization complete");
}

async Task UpdateDepartmentAsync(int employeeId, string department)
{
	using DemoContext context = new();
	Employee? employee = await context.Employees.FindAsync(employeeId);
	if (employee is not null)
	{
		employee.Department = department;
		await context.SaveChangesAsync();
	}
	_updateDateTime = DateTime.UtcNow;
}

async Task DeleteEmployeeAsync(int employeeId)
{
	using DemoContext context = new();
	Employee? employee = await context.Employees.FindAsync(employeeId);
	if (employee is not null)
	{
		context.Employees.Remove(employee);
		await context.SaveChangesAsync();
	}
}

void PrintEmployeeHistory(int employeeId)
{
	using DemoContext context = new();
	var history = context.Employees.TemporalAll().Where(emp => emp.Id == 2)
								.OrderByDescending(emp => EF.Property<DateTime>(emp, "PeriodStart"))
								.Select(emp => new
								{
									Employee = emp,
									PeriodStart = EF.Property<DateTime>(emp, "PeriodStart"),
									PeriodEnd = EF.Property<DateTime>(emp, "PeriodEnd")
								}).ToList();


	Console.WriteLine("Id\tFirstName\tLastName\tDepartment\tPeriodStart\t\tPeriodEnd");
	foreach (var something in history)
		Console.WriteLine($"{something.Employee.Id}\t{something.Employee.FirstName}\t\t{something.Employee.LastName}\t\t{something.Employee.Department}\t\t{something.PeriodStart}\t{something.PeriodEnd}");

}

async Task PrintEmployeeAsOfDateTimeAsync(int employeeId, DateTime dateTime)
{
	using DemoContext context = new();
	Employee? employee = await context.Employees.FindAsync(employeeId);
	Employee? historicalEmployee = await context.Employees
		.TemporalAsOf(dateTime)
		.FirstOrDefaultAsync(x => x.Id == employeeId);
	if (employee is not null && historicalEmployee is not null)
	{
		Console.WriteLine("State\t\tId\tFirstName\tLastName\tDepartment");
		Console.WriteLine($"Current\t\t{employee.Id}\t{employee.FirstName}\t\t{employee.LastName}\t\t{employee.Department}");
		Console.WriteLine($"Historical\t{historicalEmployee.Id}\t{historicalEmployee.FirstName}\t\t{historicalEmployee.LastName}\t\t{historicalEmployee.Department}");
	}
}

async Task RestoreDeletedEmployeeAsync(int employeeId)
{
	using DemoContext context = new();
	DateTime delTimestamp = await context.Employees.TemporalAll().Where(x => x.Id == employeeId).OrderBy(x => EF.Property<DateTime>(x, "PeriodEnd")).Select(x => EF.Property<DateTime>(x, "PeriodEnd")).LastAsync();
	Employee deletedEmployee = await context.Employees.TemporalAsOf(delTimestamp.AddMilliseconds(-1)).SingleAsync(x => x.Id == employeeId);
	await context.AddAsync(deletedEmployee);
	context.Database.OpenConnection();
	context.Database.ExecuteSqlInterpolated($"SET IDENTITY_INSERT Employee ON");
	await context.SaveChangesAsync();
	context.Database.ExecuteSqlInterpolated($"SET IDENTITY_INSERT Employee OFF");
}