locals {
  server_name = "${var.vm_prefix_name}-1"
}

resource "azurerm_public_ip" "server" {
  name                = "${local.server_name}-pubip"
  allocation_method   = "Dynamic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_network_interface" "server" {
  name                = "${local.server_name}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags

  ip_configuration {
    name                          = azurerm_public_ip.server.name
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server.id
  }
}

resource "azurerm_linux_virtual_machine" "server" {
  name                  = local.server_name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = var.vm_username
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [ azurerm_network_interface.server.id ]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.vm_username
    public_key = file(var.vm_user_pubkey_file)      
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
      curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - server --write-kubeconfig-mode 644
    SCRIPT
  )

}

resource "random_password" "k3s_token" {
  length  = 16
  special = false
}
