# Server

locals {
  serverName = "${var.vmPrefixName}-1"
}

resource "azurerm_public_ip" "server" {
  name                = "${local.serverName}-pubip"
  allocation_method   = "Dynamic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_network_interface" "server" {
  name                = "${local.serverName}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = azurerm_public_ip.server.name
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server.id
  }
}

resource "azurerm_linux_virtual_machine" "server" {
  name                  = local.serverName
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vmSize
  admin_username        = var.vmUsername
  network_interface_ids = [ azurerm_network_interface.server.id ]

  admin_ssh_key {
    username   = var.vmUsername
    public_key = file(var.vmUserPubKeyFile)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  
  custom_data = base64encode(
    <<-SCRIPT
      #!/bin/bash
      curl -sfL https://get.k3s.io | K3S_TOKEN=${var.k3sToken} sh -s - server
    SCRIPT
  )

}
