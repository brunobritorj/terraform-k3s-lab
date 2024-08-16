variable "location" {
  description = "Region where the Azure resources will be created"
  type        = string
  default     = "eastus"
}

variable "rg_name" {
  description = "Resource Group to be created"
  type        = string
  default     = "RG-TEST"
}

variable "vnet_specs" {
  description         = "Virtual Network(s) specifications to be created"
  type    = object({
    name           = string
    address_space  = string
    subnet_name    = string
    subnet_address = string
  })
  default = {
    name           = "VNET-10-16"
    address_space  = "10.0.0.0/16"
    subnet_name    = "SNET-10-24"
    subnet_address = "10.0.0.0/24"
  }
}

variable "vm_username" {
  description = "Username to connect to VM(s)"
  type        = string
  default     = "bruno"
}

variable "vm_user_pubkey_file" {
  description = "Path to the user PUBLIC key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_prefix_name" {
  description = "Prefix used for naming VM(s)"
  type        = string
  default     = "VM"
}

variable "vm_size" {
  description = "VM Sizes"
  type        = string
  default     = "Standard_A1_v2"
}

variable "tags" {
  type  = map(string)
  default = {
    env = "lab"
  }
}
