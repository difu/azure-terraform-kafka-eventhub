resource "azurerm_virtual_network" "eh_network" {
  name                = "eventhub-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.eh_rg.location
  resource_group_name = azurerm_resource_group.eh_rg.name
}

resource "azurerm_subnet" "eh_subnet" {
  name                 = "eventhub-subnet"
  resource_group_name  = azurerm_resource_group.eh_rg.name
  virtual_network_name = azurerm_virtual_network.eh_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "eh_vm_public_ip" {
  name                = "eventhub-PublicIP"
  location            = azurerm_resource_group.eh_rg.location
  resource_group_name = azurerm_resource_group.eh_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "eh_vm_nsg" {
  name                = "eventhub-NetworkSecurityGroup"
  location            = azurerm_resource_group.eh_rg.location
  resource_group_name = azurerm_resource_group.eh_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "eventhub-myNIC"
  location            = azurerm_resource_group.eh_rg.location
  resource_group_name = azurerm_resource_group.eh_rg.name

  ip_configuration {
    name                          = "eventhub-nic-configuration"
    subnet_id                     = azurerm_subnet.eh_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.eh_vm_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "my-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.eh_vm_nsg.id
}

