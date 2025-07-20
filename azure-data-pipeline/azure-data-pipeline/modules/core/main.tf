```hcl
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-adf"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-adf"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.datafactory.azure.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_enabled         = true
}

resource "azurerm_key_vault_access_policy" "adf" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_data_factory.main.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_mssql_server" "main" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "main" {
  name               = var.sql_database_name
  server_id          = azurerm_mssql_server.main.id
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  sku_name           = "S0"
  max_size_gb        = 5
  zone_redundant     = false
}

resource "azurerm_data_factory" "main" {
  name                = var.adf_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  identity {
    type = "SystemAssigned"
  }
  github_configuration {
    account_name = var.github_account_name
    repository_name = var.github_repo_name
    collaboration_branch = var.github_branch
    root_folder = "/"
  }
}

resource "azurerm_data_factory_integration_runtime_azure" "auto" {
  name            = "auto-ir"
  data_factory_id = azurerm_data_factory.main.id
  location        = var.location
}

resource "azurerm_private_endpoint" "adf" {
  name                = "adf-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.main.id
  private_service_connection {
    name                           = "adf-pe-conn"
    private_connection_resource_id = azurerm_data_factory.main.id
    subresource_names              = ["dataFactory"]
  }
}

resource "azurerm_databricks_workspace" "main" {
  name                = var.databricks_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "standard"
}

resource "azurerm_data_factory_linked_service_azure_databricks" "main" {
  name                = "AzureDatabricksLinkedService"
  resource_group_name = azurerm_resource_group.main.name
  data_factory_name   = azurerm_data_factory.main.name
  description         = "Databricks LS"
  adb_domain          = azurerm_databricks_workspace.main.workspace_url
  access_token        = var.databricks_token
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "sql" {
  name                = "AzureSQLLinkedService"
  resource_group_name = azurerm_resource_group.main.name
  data_factory_name   = azurerm_data_factory.main.name
  connection_string   = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};"
}

resource "azurerm_data_factory_dataset_sql_server_table" "sql_table" {
  name                = "SqlTableDataset"
  data_factory_id     = azurerm_data_factory.main.id
  linked_service_name = azurerm_data_factory_linked_service_azure_sql_database.sql.name
  table_name          = "my_table"
  schema              = "dbo"
}

resource "azurerm_data_factory_pipeline" "main" {
  name                = "MainPipeline"
  data_factory_id     = azurerm_data_factory.main.id
  activities_json     = file("${path.module}/pipeline.json")
}

resource "azurerm_data_factory_trigger_schedule" "daily" {
  name                = "DailyTrigger"
  data_factory_id     = azurerm_data_factory.main.id
  pipeline_name       = azurerm_data_factory_pipeline.main.name
  start_time          = "2023-01-01T00:00:00Z"
  recurrence {
    frequency = "Day"
    interval  = 1
  }
}