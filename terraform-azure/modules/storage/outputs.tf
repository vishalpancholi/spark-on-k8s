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

output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.main.id
}