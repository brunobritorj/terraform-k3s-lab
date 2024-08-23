locals {
  
  ssh_folder        = "/home/vscode/.ssh"
  server_admin_name = "vscode"
  server_gw_name    = "${var.vm_prefix_name}-gw"

  k3s_servers_for_config_files = [
    for vm in azurerm_linux_virtual_machine.k3s_server : {
      name = vm.computer_name
      ip   = vm.private_ip_address
    }
  ]

  k3s_list = [
    for idx, vm in azurerm_linux_virtual_machine.k3s_server : {
      name = "k3s-${tostring(idx)}"
      ip   = vm.private_ip_address
    }
  ]
}
