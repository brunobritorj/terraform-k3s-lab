resource "azurerm_public_ip" "server_gw" {
  name                = "${local.server_gw_name}-pubip"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_network_interface" "server_gw" {
  name                = "${local.server_gw_name}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags

  ip_configuration {
    name                          = "${local.server_gw_name}-ip1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server_gw.id
  }
}

resource "azurerm_linux_virtual_machine" "server_gw" {
  name                  = local.server_gw_name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = local.server_admin_name
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [azurerm_network_interface.server_gw.id]
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
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.server_gw.ip_address
      user        = local.server_admin_name
      private_key = tls_private_key.ssh_key.private_key_openssh
    }
    content     = templatefile("files/haproxy.cfg.tpl", {vms = local.k3s_servers_for_config_files})
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.server_gw.ip_address
      user        = local.server_admin_name
      private_key = tls_private_key.ssh_key.private_key_openssh
    }
    inline = [
      "sudo apt update && sudo apt install haproxy -y",
      "sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo systemctl reload haproxy"
    ]
  }
}

output "server_public_ip" {
  value = azurerm_linux_virtual_machine.server_gw.public_ip_address
  description = "Public IP address"
  depends_on  = [
    azurerm_linux_virtual_machine.server_gw,
    azurerm_public_ip.server_gw
  ]
}
