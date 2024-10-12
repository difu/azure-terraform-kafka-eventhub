resource "azurerm_storage_account" "eh_storage_account" {
  name                     = "difuehstorage"
  resource_group_name      = azurerm_resource_group.eh_rg.name
  location                 = azurerm_resource_group.eh_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "eh_sacontainer" {
  name                  = "ehdata"
  storage_account_name  = azurerm_storage_account.eh_storage_account.name
  container_access_type = "blob"
}

output "BLOB_STORAGE_ACCOUNT_URL" {
  value = azurerm_storage_account.eh_storage_account.primary_blob_endpoint
}

output "BLOB_CONTAINER_NAME" {
    value = azurerm_storage_container.eh_sacontainer.name
}