resource "azurerm_resource_group" "dockerwp" {
  name     = "dockerwp"
  location = "South India"

  tags = {
    environment = "dockerwp"
  }
}