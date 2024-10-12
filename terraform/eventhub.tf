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

resource "azurerm_eventhub_namespace_authorization_rule" "ns_sap_listen" {
  name                = "ns_sap_listen"
  namespace_name      = azurerm_eventhub_namespace.eh_namespace.name
  resource_group_name = azurerm_eventhub_namespace.eh_namespace.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

output "eventhub_connection_string" {
  value = azurerm_eventhub_namespace.eh_namespace.default_primary_connection_string
  sensitive = true
}

output "EVENT_HUB_FULLY_QUALIFIED_NAMESPACE" {
  value = azurerm_eventhub_namespace.eh_namespace.default_primary_connection_string
  sensitive = true
}

output "EVENT_HUB_NAME" {
  value = azurerm_eventhub.eh_eventhub.name
}

output "eventhub_connection_string_listen" {
  value = azurerm_eventhub_namespace_authorization_rule.ns_sap_listen.primary_connection_string
  sensitive = true
}