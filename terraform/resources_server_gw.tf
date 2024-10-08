resource "azurerm_public_ip" "gw" {
  name                = "${var.vm_prefix_name}-gw-pubip"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  domain_name_label   = var.ip_dns_label
  tags                = var.tags
}

resource "azurerm_network_interface" "gw" {
  name                = "${var.vm_prefix_name}-gw-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags

  ip_configuration {
    name                          = "${var.vm_prefix_name}-gw-ip1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gw.id
  }
}

resource "azurerm_linux_virtual_machine" "gw" {
  name                  = "${var.vm_prefix_name}-gw"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = local.server_admin_name
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [azurerm_network_interface.gw.id]
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.gw.ip_address
      user        = local.server_admin_name
      private_key = tls_private_key.ssh_key.private_key_openssh
    }
    inline = [
      "sudo apt update",
      "echo Waiting for package list update",
      "sleep 120",
      "sudo apt install haproxy -y",
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.gw.ip_address
      user        = local.server_admin_name
      private_key = tls_private_key.ssh_key.private_key_openssh
    }
    content     = templatefile("files/haproxy.cfg.tpl", {vms = local.k3s_list})
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.gw.ip_address
      user        = local.server_admin_name
      private_key = tls_private_key.ssh_key.private_key_openssh
    }
    inline = [
      "until systemctl is-active --quiet haproxy; do echo 'Waiting for HAProxy to start...'; sleep 5; done",
      "sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo systemctl reload haproxy"
    ]
  }
}

output "gw_public_ip" {
  value = azurerm_public_ip.gw.ip_address
  description = "Public IP address"
}
