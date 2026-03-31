resource "azurerm_resource_group" "rg-vmmon-setup" {
  name     = var.resource_group_name
  location = var.location
}
