# ============================================================================
# TIME TRAVELLING DATA: Terraform Outputs
# ============================================================================
# Use these outputs to connect to the provisioned SQL Database
# ============================================================================

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.temporal_demo.fully_qualified_domain_name
}

output "database_name" {
  description = "Name of the temporal demo database"
  value       = azurerm_mssql_database.temporal_demo.name
}

output "connection_string" {
  description = "ADO.NET connection string for SSMS or application use"
  value       = "Server=tcp:${azurerm_mssql_server.temporal_demo.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.temporal_demo.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

output "ssms_connection_info" {
  description = "Connection details for SQL Server Management Studio"
  value = {
    server   = azurerm_mssql_server.temporal_demo.fully_qualified_domain_name
    database = azurerm_mssql_database.temporal_demo.name
    username = var.sql_admin_username
    auth     = "SQL Server Authentication"
  }
}

output "ef_demo_database_name" {
  description = "Name of the EF Core demo SQL database"
  value       = azurerm_mssql_database.temporal_ef_demo.name
}

output "ef_demo_connection_string" {
  description = "Connection string for the EF Core demo database (update with actual password)"
  value       = "Server=tcp:${azurerm_mssql_server.temporal_demo.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.temporal_ef_demo.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=<your-password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = false
}

# ============================================================================
# HOW TO USE THESE OUTPUTS
# ============================================================================
# After running 'terraform apply', retrieve outputs with:
#
#   terraform output sql_server_fqdn
#   terraform output database_name
#   terraform output -raw connection_string   # -raw flag removes quotes
#
# For SSMS connection:
#   1. Open SQL Server Management Studio
#   2. Server name: <value from sql_server_fqdn>
#   3. Authentication: SQL Server Authentication
#   4. Login: <value from var.sql_admin_username>
#   5. Password: <value from var.sql_admin_password>
#   6. Connect to database: TemporalDemo
# ============================================================================
