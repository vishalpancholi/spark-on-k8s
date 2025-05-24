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


variable "container_definitions" {
  description = "A map of objects defining the storage containers to create. Keys are internal identifiers."
  type = map(object({
    name                 = string
    container_access_type = optional(string, "private")
  }))
  default = {} # Default to an empty map if no containers are specified
}