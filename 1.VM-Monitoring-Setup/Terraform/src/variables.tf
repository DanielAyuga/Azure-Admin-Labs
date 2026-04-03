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

variable "law_name" {
  type        = string
  description = "Nombre del Log Analytics Workspace"
}

variable "dcr_name" {
  type        = string
  description = "Nombre de la Data Collection Rule"
}

variable "vm_workbook_name" {
  type        = string
  description = "Nombre del Workbook para VM"
}

variable "action_group_name" {
  type        = string
  description = "Nombre del Action Group para alertas"
}

variable "alert_email" {
  type        = string
  description = "Correo que recibirá las alertas"
}