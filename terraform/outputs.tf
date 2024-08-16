output "server_ip" {
  value        = azurerm_linux_virtual_machine.server.public_ip_address
  description  = "Server IPv4 address"
  depends_on   = [
    azurerm_linux_virtual_machine.server,
    azurerm_public_ip.server
  ]
}
