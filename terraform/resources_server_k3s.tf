resource "azurerm_network_interface" "k3s" {
  count = var.vm_k3_nodes

  name                = "${var.vm_prefix_name}-k3s${count.index}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags

  ip_configuration {
    name                          = "${var.vm_prefix_name}-k3s${count.index}-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.vnet_specs.subnet_address, 10 + count.index)
  }
}

resource "azurerm_linux_virtual_machine" "k3s" {
  count = var.vm_k3_nodes

  name                  = "${var.vm_prefix_name}-k3s${count.index}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = local.server_admin_name
  admin_password        = random_password.vm_admin.result
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [azurerm_network_interface.k3s[count.index].id]
  tags                  = var.tags

  admin_ssh_key {
    username   = local.server_admin_name
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(
    count.index == 0 ? local.k3s_cmds_server : local.k3s_cmds_agent
  )

  depends_on = [azurerm_linux_virtual_machine.gw]
}
