#Llamada a modulo "resource_group"
module "resource_group" {
  source   = "./modules/resource-group"
  rg_name  = var.rg_name
  location = var.location
}

#Llamada a modulo "networking"
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

#Llamada a modulo "compute"
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

#Llamada a modulo "monitoring"
module "monitoring" {
  source   = "./modules/monitoring"
  rg_name  = module.resource_group.rg_name
  location = module.resource_group.rg_location

  vm_id    = module.compute.vm_id
  vm_name  = var.vm_name

  law_name          = var.law_name
  dcr_name          = var.dcr_name
  vm_workbook_name  = var.vm_workbook_name
  action_group_name = var.action_group_name
  alert_email       = var.alert_email
}