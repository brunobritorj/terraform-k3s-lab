resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_specs.name
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_specs.address_space]
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = var.vnet_specs.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.vnet_specs.subnet_address]
}

resource "azurerm_availability_set" "main" {
  name                = "${var.vm_prefix_name}-k3s-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}
