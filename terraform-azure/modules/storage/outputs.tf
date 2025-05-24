// Defines output values for the Storage module.
output "storage_account_primary_access_key" {
  description = "The primary access key for the Storage Account."
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.main.name
}

# Output the storage account ID for role assignments in the root module
output "storage_account_id" {
  value = azurerm_storage_account.main.id
  description = "The ID of the created storage account."
}

# Output the names of the created containers
output "container_names_created" {
  value = [for s in azurerm_storage_container.containers : s.name]
  description = "A list of names of the created storage containers."
}