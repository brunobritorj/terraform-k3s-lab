resource "local_file" "ssh_private_key" {
  filename        = "${local.ssh_folder}/lab_id_rsa"
  content         = tls_private_key.ssh_key.private_key_openssh
  file_permission = 600

  depends_on = [tls_private_key.ssh_key]
}

resource "local_file" "ssh_public_key" {
  filename        = "${local.ssh_folder}/lab_id_rsa.pub"
  content         = tls_private_key.ssh_key.public_key_openssh
  file_permission = 600

  depends_on = [tls_private_key.ssh_key]
}

resource "local_file" "ssh_config" {
  filename = "${local.ssh_folder}/config"
  content  = templatefile("files/ssh_config.tpl", {
    username  = local.server_admin_name,
    public_ip = azurerm_public_ip.server_gw.ip_address,
    vms       = local.k3s_list
  })
}
