# ============================================================================
# TIME TRAVELLING DATA: Terraform Variables
# ============================================================================
# Configure these values in terraform.tfvars (see terraform.tfvars.example)
# ============================================================================

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-temporal-tables-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "sql_server_name" {
  description = "Name of the Azure SQL Server (must be globally unique across all of Azure)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.sql_server_name))
    error_message = "SQL Server name must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
  
  validation {
    condition     = !contains(["admin", "administrator", "sa", "root"], lower(var.sql_admin_username))
    error_message = "SQL admin username cannot be 'admin', 'administrator', 'sa', or 'root'."
  }
}

variable "sql_admin_password" {
  description = "Administrator password for SQL Server (must be complex)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.sql_admin_password) >= 12
    error_message = "SQL admin password must be at least 12 characters long."
  }
}

variable "presenter_ip_address" {
  description = "Your public IP address for SSMS access. Find it at https://whatismyip.com or run 'curl ifconfig.me'"
  type        = string
  
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.presenter_ip_address))
    error_message = "Presenter IP must be a valid IPv4 address (e.g., 203.0.113.45)."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "demo"
    project     = "temporal-tables"
  }
}
