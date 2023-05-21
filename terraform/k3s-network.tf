# Shared resources

resource "azurerm_resource_group" "main" {
  name      = var.resourceGroupName
  location  = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnetSpecs.name
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [ var.vnetSpecs.addressSpace ]
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet" "main" {
  name                 = var.vnetSpecs.subnetName
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [ var.vnetSpecs.subnetAddress ]
}
