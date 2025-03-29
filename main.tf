provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "f1" {
  name     = "formula1-rg"
  location = "West US"
}

resource "azurerm_storage_account" "f1" {
  name                     = "formula1dl"
  resource_group_name      = azurerm_resource_group.f1.name
  location                 = azurerm_resource_group.f1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.f1.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "processed" {
  name               = "processed"
  storage_account_id = azurerm_storage_account.f1.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "presentation" {
  name               = "presentation"
  storage_account_id = azurerm_storage_account.f1.id
}

resource "azurerm_databricks_workspace" "f1" {
  name                = "formula1-databricks"
  resource_group_name = azurerm_resource_group.f1.name
  location            = azurerm_resource_group.f1.location
  sku                 = "standard"
}

resource "azurerm_key_vault" "f1" {
  name                        = "formula1-kv"
  resource_group_name         = azurerm_resource_group.f1.name
  location                    = azurerm_resource_group.f1.location
  tenant_id                   = "MY_TENANT_ID"
  sku_name                    = "standard"
}

resource "azurerm_key_vault_secret" "databricks_client_id" {
  name         = "databricks-client-id"
  value        = "MY_DATABRICKS_CLIENT_ID"
  key_vault_id = azurerm_key_vault.f1.id
}

resource "azurerm_key_vault_secret" "databricks_client_secret" {
  name         = "databricks-client-secret"
  value        = "MY_DATABRICKS_CLIENT_SECRET"
  key_vault_id = azurerm_key_vault.f1.id
}

resource "azurerm_role_assignment" "databricks_storage" {
  scope                = azurerm_storage_account.f1.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = "MY_DATABRICKS_SP_OBJECT_ID"
}
