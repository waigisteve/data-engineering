output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "data_factory_name" {
  value = azurerm_data_factory.main.name
}

output "data_factory_url" {
  value = "https://${azurerm_data_factory.main.location}.adf.azure.com"
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_primary_key" {
  value     = azurerm_storage_account.main.primary_access_key
  sensitive = true
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "databricks_url" {
  value = azurerm_databricks_workspace.main.workspace_url
}
