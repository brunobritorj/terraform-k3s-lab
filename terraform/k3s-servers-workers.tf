# Servers/Agents
# If vmCount is greater than or equals to 2, it will deploy this/these server(s) as K3s Agent(s)

resource "azurerm_public_ip" "workers" {
  count               = var.vmCount -1
  name                = "${var.vmPrefixName}-${count.index +2}-pubip"
  allocation_method   = "Dynamic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_network_interface" "workers" {
  count               = var.vmCount -1
  name                = "${var.vmPrefixName}-${count.index +2}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = azurerm_public_ip.workers[count.index].name
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.workers[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "workers" {
  count                 = var.vmCount -1
  name                  = "${var.vmPrefixName}-${count.index +2}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vmSize
  admin_username        = var.vmUsername
  network_interface_ids = [ azurerm_network_interface.workers[count.index].id ]

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
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='agent --server https://${var.vmPrefixName}-1:6443/ --token ${var.k3sToken}' sh -s -
    SCRIPT
  )

  depends_on = [ azurerm_linux_virtual_machine.server ]
}
