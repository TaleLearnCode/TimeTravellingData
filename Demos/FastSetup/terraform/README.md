# Terraform Deployment Guide

This directory contains Terraform configuration to provision Azure SQL infrastructure for **both** Time Travelling Data fast demos:

| Resource | Used By |
|----------|---------|
| Azure SQL Server | Demo 1 (SQLDemoFast) + Demo 2 (EFCoreDemoFast) |
| `TemporalDemo` database | Demo 1 — SQLDemoFast (T-SQL + SSMS) |
| `TemporalEFDemo` database | Demo 2 — EFCoreDemoFast (EF Core) |

Both demos share one server. You only need to run `terraform apply` once before either demo.

## Prerequisites

1. **Azure CLI** — Install from https://aka.ms/azure-cli
2. **Terraform** — Version >= 1.3 (required by azurerm v4 provider)
   - Install from https://terraform.io/downloads
3. **Azure Subscription** — Active subscription with permissions to create resources
4. **Azure Provider v4** — This configuration uses azurerm v4, which requires:
   - `subscription_id` must be set in `terraform.tfvars` (or via `ARM_SUBSCRIPTION_ID` environment variable)

## Setup Steps

### 1. Authenticate to Azure

```bash
az login
az account show  # Verify you're in the correct subscription
az account set --subscription "YOUR-SUBSCRIPTION-ID"  # If needed
```

### 2. Configure Variables

Copy the example variables file and edit it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:

- **sql_server_name**: Must be globally unique across ALL of Azure
  - Suggestion: `sql-temporal-demo-YOUR-INITIALS-RANDOM`
  - Example: `sql-temporal-demo-mg-x7k2p`
  - Test uniqueness: `az sql server check-name --name YOUR-NAME`

- **sql_admin_password**: Strong password meeting Azure requirements
  - Minimum 12 characters
  - Must include uppercase, lowercase, numbers, and symbols
  - Example: `P@ssw0rd!2025Demo`

- **presenter_ip_address**: Your public IP for SSMS access
  - Find it: https://whatismyip.com or run `curl ifconfig.me`
  - Example: `203.0.113.45`

### 3. Initialize Terraform

```bash
terraform init
```

This downloads the Azure provider and prepares the workspace.

### 4. Plan the Deployment

```bash
terraform plan
```

Review the planned changes. You should see:
- 1 Resource Group
- 1 SQL Server
- 2 SQL Databases (`TemporalDemo` + `TemporalEFDemo`)
- 2 Firewall Rules

### 5. Deploy to Azure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes ~5 minutes.

### 6. Get Connection Details

After deployment completes:

```bash
# Get the SQL Server FQDN (fully qualified domain name)
terraform output sql_server_fqdn

# Demo 1 — SQLDemoFast connection info (for SSMS)
terraform output ssms_connection_info

# Demo 2 — EFCoreDemoFast connection string (paste into appsettings.json)
terraform output -raw ef_demo_connection_string
```

### 7. Connect in SSMS

1. Open **SQL Server Management Studio**
2. **Server name**: `<value from sql_server_fqdn>` (e.g., `sql-temporal-demo-mg.database.windows.net`)
3. **Authentication**: SQL Server Authentication
4. **Login**: `sqladmin` (or your custom username)
5. **Password**: `<value from terraform.tfvars>`
6. Click **Connect**
7. In Object Explorer, expand **Databases** → you should see **TemporalDemo**

### 8. Run the Demo Scripts

Now that the infrastructure is provisioned:

**Demo 1 — SQLDemoFast** (connect to `TemporalDemo` in SSMS):
1. **01-Setup.sql** — Creates temporal table, inserts data, seeds history
2. **02-Observe.sql** — Shows live DML changes being tracked
3. **03-TimeTravel.sql** — Demonstrates FOR SYSTEM_TIME queries

**Demo 2 — EFCoreDemoFast** (update `appsettings.json` connection string):
```bash
cd ../../EFCoreDemoFast
# Edit appsettings.json — use the ef_demo_connection_string output above
dotnet run
```

## Troubleshooting

### Connection Fails from SSMS

**Problem**: "Cannot open server 'XXX' requested by the login"

**Solution**: Verify firewall rules
```bash
# Check if your IP is correct
curl ifconfig.me

# Update firewall rule if IP changed
terraform apply -var="presenter_ip_address=NEW-IP-ADDRESS"
```

### SQL Server Name Already Exists

**Problem**: "The server name 'XXX' is already taken"

**Solution**: SQL server names are globally unique. Change `sql_server_name` in `terraform.tfvars` to something unique (add random suffix).

### Authentication Fails

**Problem**: "Login failed for user 'sqladmin'"

**Solution**: Verify password in `terraform.tfvars` matches what you're entering in SSMS. Remember it's case-sensitive.

## Cleanup

When you're done with the demo, tear down all resources to avoid Azure charges:

```bash
terraform destroy
```

Type `yes` when prompted. This deletes:
- SQL Database
- SQL Server
- Firewall Rules
- Resource Group

**Cost Note**: The S0 database costs ~$15/month. If you keep it running for a 1-hour demo, the cost is negligible (~$0.02).

## Security Notes

- **terraform.tfvars** is git-ignored (contains passwords)
- **terraform.tfstate** is git-ignored (contains sensitive state)
- Never commit credentials to source control
- Use Azure Key Vault for production deployments
- Rotate the SQL admin password after demos if shared with others

## Advanced Options

### Use Different Azure Region

Edit `terraform.tfvars`:
```hcl
location = "West US 2"
```

### Change Database SKU

Edit `main.tf` (azurerm_mssql_database resource):
```hcl
sku_name = "Basic"  # Even cheaper for small demos
# or
sku_name = "S1"     # More DTUs if database is slow
```

### Allow All IPs (for Conference WiFi)

If presenting from an unknown network, temporarily allow all IPs.

**Warning**: This is insecure for production, but acceptable for ephemeral demos.

Add to `main.tf`:
```hcl
resource "azurerm_mssql_firewall_rule" "allow_all" {
  name             = "AllowAll-TEMP"
  server_id        = azurerm_mssql_server.temporal_demo.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
```

Then run `terraform apply`.

## Additional Resources

- Azure SQL Temporal Tables Docs: https://learn.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables
- Terraform Azure Provider Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- SSMS Download: https://aka.ms/ssms
