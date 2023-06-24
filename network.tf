resource "azurerm_virtual_network" "dockerwpvn" {
   name                = "acctvn"
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.dockerwp.location
   resource_group_name = azurerm_resource_group.dockerwp.name
 }

resource "azurerm_subnet" "dockerwpsub" {
   name                 = "acctsub"
   resource_group_name  = azurerm_resource_group.dockerwp.name
   virtual_network_name = azurerm_virtual_network.dockerwpvn.name
   address_prefixes     = ["10.0.2.0/24"]
}