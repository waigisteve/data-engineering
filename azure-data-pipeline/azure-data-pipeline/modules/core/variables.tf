variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Azure Storage account"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "adf_name" {
  description = "Name of the Azure Data Factory instance"
  type        = string
}

variable "github_account_name" {
  description = "GitHub account/org name for ADF integration"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name for ADF integration"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch for collaboration"
  type        = string
}

variable "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
}

variable "databricks_token" {
  description = "Databricks PAT token"
  type        = string
  sensitive   = true
}
