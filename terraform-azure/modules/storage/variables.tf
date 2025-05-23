// Defines input variables for the Storage module.
variable "resource_group_name" {
  description = "Name of the Azure Resource Group where Storage will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the Storage Account."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account."
  type        = string
}

variable "storage_container_name" {
  description = "Name of the blob container to create within the Storage Account."
  type        = string
}
