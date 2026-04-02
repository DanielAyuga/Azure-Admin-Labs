variable "rg_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Región donde se desplegarán los recursos"
  type        = string
}

variable "vnet_name" {
  description = "Nombre de la VNet"
  type        = string
}

variable "subnet_name" {
  description = "Nombre de la Subnet"
  type        = string
}

variable "nsg_name" {
  description = "Nombre del NSG"
  type        = string
}

variable "nic_name" {
  description = "Nombre de la NIC"
  type        = string
}

variable "my_public_ip" {
  description = "Tu IP pública para permitir acceso"
  type        = string
}