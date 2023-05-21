variable "location" {
  description = "Region where the Azure resources will be created"
  type        = string
  default     = "eastus"
}

variable "resourceGroupName" {
  description = "Resource Group to be created"
  type        = string
  default     = "RG-TEST"
}

variable "vnetSpecs" {
  description         = "Virtual Network(s) specifications to be created"
  type = object({
    name              = string
    addressSpace      = string
    subnetName        = string
    subnetAddress     = string
  })
  default = {
    name              = "VNET-10-16"
    addressSpace      = "10.0.0.0/16"
    subnetName        = "SNET-10-24"
    subnetAddress     = "10.0.0.0/24"
  }
}

variable "vmUsername" {
  description = "Username to connect to VM(s)"
  type        = string
  default     = "bruno"
}

variable "vmUserPubKeyFile" {
  description = "Path to the user PUBLIC key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vmUserPrivKeyFile" {
  description = "Path to the user PRIVATE key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "vmPrefixName" {
  description = "Prefix used for naming VM(s)"
  type        = string
  default     = "VM"
}

variable "vmSize" {
  description = "VM Sizes"
  type        = string
  default     = "Standard_A1_v2"
}

variable "vmCount" {
  description = "VM Sizes"
  type        = number
  default     = 2
  validation {
    condition     = var.vmCount >= 1 && var.vmCount <= 9
    error_message = "Value must be between 1 and 9"
  }
}

variable "k3sToken" {
  description = "K3s Token"
  type        = string
  default     = "12345"
}
