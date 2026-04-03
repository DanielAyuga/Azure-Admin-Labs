variable "rg_name" {
  type        = string
  description = "Nombre del grupo de recursos"
}

variable "location" {
  type        = string
  description = "Región"
  default     = "spaincentral"
}

variable "vnet_name" {
  type        = string
}

variable "subnet_name" {
  type        = string
}

variable "nsg_name" {
  type        = string
}

variable "nic_name" {
  type        = string
}

variable "my_public_ip" {
  type        = string
}

variable "vm_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}
