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
  description = "Virtual Network(s) specifications to be created"
  type = object({
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

variable "vm_k3_nodes" {
  description = "How many K3s nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.vm_k3_nodes >= 1 && var.vm_k3_nodes <= 5
    error_message = "Value must be between 1 and 5"
  }
}

variable "ip_dns_label" {
  description = "(optional) Label for DNS name of the Az Public IP"
  type        = string
  default     = "bbrj-k3s-lab"
}

variable "tags" {
  type = map(string)
  default = {
    env = "lab"
  }
}
