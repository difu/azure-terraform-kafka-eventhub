resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "eh_vm" {
  name                  = "eventhub-VM"
  location              = azurerm_resource_group.eh_rg.location
  resource_group_name   = azurerm_resource_group.eh_rg.name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "eventhub-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "eventhub-vm"
  admin_username                  = "secureadmin"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "secureadmin"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.eh_vm.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.secureadmin_ssh.private_key_pem
  sensitive = true
}