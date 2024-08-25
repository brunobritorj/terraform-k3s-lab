locals {
  
  # DevContainer image parameters
  home_folder        = "/home/vscode"
  server_admin_name = "vscode"

  # K3s parameters
  k3s_cmds_server = <<-SCRIPT
      #!/bin/bash
      curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} sh -s - server --write-kubeconfig-mode 644
      sudo snap install helm --classic
    SCRIPT
  k3s_cmds_agent  = <<-SCRIPT
      #!/bin/bash
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='agent --server https://${var.vm_prefix_name}-k3s-0:6443 --token ${random_password.k3s_token.result}' sh -s -
    SCRIPT
  k3s_list = [
    for i in range(var.vm_k3_nodes) : {
      name = "k3s${i}"
      ip   = cidrhost(var.vnet_specs.subnet_address, 10 + i)
    }
  ]
}

