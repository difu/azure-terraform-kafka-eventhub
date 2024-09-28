resource "azurerm_eventhub_namespace" "eh_namespace" {
  name                = "difueventhubnamespace"
  location            = azurerm_resource_group.eh_rg.location
  resource_group_name = azurerm_resource_group.eh_rg.name
  sku                 = "Standard"

}

resource "azurerm_eventhub" "eh_eventhub" {
  name                = "difuexampleeventhub"
  namespace_name      = azurerm_eventhub_namespace.eh_namespace.name
  resource_group_name = azurerm_resource_group.eh_rg.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "eh_consumergroup" {
  name                = "difuexampleconsumergroup"
  namespace_name      = azurerm_eventhub_namespace.eh_namespace.name
  eventhub_name       = azurerm_eventhub.eh_eventhub.name
  resource_group_name = azurerm_resource_group.eh_rg.name
}

output "eventhub_connection_string" {
  value = azurerm_eventhub_namespace.eh_namespace.default_primary_connection_string
  sensitive = true
}