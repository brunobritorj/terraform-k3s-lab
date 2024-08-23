resource "random_password" "vm_admin" {
  length  = 16
  special = false
}

resource "random_password" "k3s_token" {
  length  = 16
  special = false
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
