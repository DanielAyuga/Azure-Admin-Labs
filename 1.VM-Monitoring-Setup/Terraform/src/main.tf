module "resource_group" {
  source   = "./modules/resource-group"
  rg_name  = var.rg_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  rg_name             = module.resource_group.rg_name
  location            = module.resource_group.rg_location

  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  nsg_name            = var.nsg_name
  nic_name            = var.nic_name

  my_public_ip        = var.my_public_ip
}

module "compute" {
  source         = "./modules/compute"
  rg_name        = module.resource_group.rg_name
  location       = module.resource_group.rg_location

  subnet_id      = module.networking.subnet_id
  nsg_id         = module.networking.nsg_id

  nic_name       = var.nic_name
  vm_name        = var.vm_name

  admin_username = var.admin_username
  admin_password = var.admin_password
}