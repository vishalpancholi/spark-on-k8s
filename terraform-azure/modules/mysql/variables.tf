// Defines input variables for the MySQL module.

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where MySQL will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "mysql_server_name" {
  description = "Name of the MySQL Flexible Server."
  type        = string
}

variable "mysql_admin_username" {
  description = "Administrator username for the MySQL server."
  type        = string
}

variable "zone" {
  description = "mysql server zone"
  type = number
}

variable "mysql_admin_password" {
  description = "Administrator password for the MySQL server."
  type        = string
  sensitive   = true
}

variable "mysql_database_name" {
  description = "Name of the database to create in MySQL server."
  type        = string
}

variable "mysql_subnet_id" {
  description = "The ID of the subnet where MySQL server will be deployed."
  type        = string
}

variable "mysql_sku_name" {
  description = "The SKU name for the MySQL server."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "mysql_storage_gb" {
  description = "Storage size in GB for the MySQL server."
  type        = number
  default     = 20
}
