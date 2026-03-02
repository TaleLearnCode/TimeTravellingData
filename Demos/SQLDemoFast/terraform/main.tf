# ============================================================================
# TIME TRAVELLING DATA: Terraform Configuration for Azure SQL
# ============================================================================
# Purpose: Provision Azure SQL Database for temporal tables demo
# Resources: Resource Group, SQL Server, SQL Database, Firewall Rules
# ============================================================================

terraform {
  required_version = ">= 1.0, < 2.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ============================================================================
# RESOURCE GROUP
# ============================================================================
# Logical container for all demo resources
# ============================================================================

resource "azurerm_resource_group" "temporal_demo" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ============================================================================
# AZURE SQL SERVER
# ============================================================================
# Logical SQL Server instance (not a VM — this is PaaS)
# Name must be globally unique across all of Azure
# ============================================================================

resource "azurerm_mssql_server" "temporal_demo" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.temporal_demo.name
  location                     = azurerm_resource_group.temporal_demo.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  
  tags = var.tags
}

# ============================================================================
# AZURE SQL DATABASE
# ============================================================================
# The actual database where we'll create temporal tables
# SKU: S0 = Standard tier, DTU-based (affordable for demos)
# ============================================================================

resource "azurerm_mssql_database" "temporal_demo" {
  name           = "TemporalDemo"
  server_id      = azurerm_mssql_server.temporal_demo.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
  
  tags = var.tags
}

# ============================================================================
# FIREWALL RULE: Allow Azure Services
# ============================================================================
# Special rule: start_ip = end_ip = 0.0.0.0 allows Azure internal services
# Useful for Azure Data Factory, Logic Apps, etc.
# ============================================================================

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.temporal_demo.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ============================================================================
# FIREWALL RULE: Allow Presenter IP
# ============================================================================
# Allows SSMS connections from the presenter's machine
# Get your IP from: https://whatismyip.com or https://ifconfig.me
# ============================================================================

resource "azurerm_mssql_firewall_rule" "allow_presenter_ip" {
  name             = "AllowPresenterIP"
  server_id        = azurerm_mssql_server.temporal_demo.id
  start_ip_address = var.presenter_ip_address
  end_ip_address   = var.presenter_ip_address
}

# ============================================================================
# END OF CONFIGURATION
# ============================================================================
# After applying this Terraform:
#   1. Get connection string from outputs: terraform output connection_string
#   2. Connect to the server in SSMS using the FQDN
#   3. Run 01-Setup.sql to create the temporal tables
# ============================================================================
