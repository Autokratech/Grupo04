#-- Creación del Resource group del proyecto

resource "azurerm_resource_group" "default" {
  name     = "autokratech-rg"
  location = "spaincentral"
}