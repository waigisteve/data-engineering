module "azure_data_pipeline" {
  source                   = "../../modules/core"

  rg_name                  = "rg-data-staging"
  location                 = "East US"
  storage_account_name     = "stagingstorageacct"
  key_vault_name           = "staging-keyvault"
  sql_server_name          = "staging-sql-server"
  sql_database_name        = "stagingdb"
  sql_admin_username       = "adminuser"
  sql_admin_password       = var.sql_admin_password
  adf_name                 = "staging-adf"
  databricks_workspace_name = "staging-dbx"
  github_account_name      = var.github_account_name
  github_repo_name         = var.github_repo_name
  github_branch            = var.github_branch
  databricks_token         = var.databricks_token
}
