// Defines Azure Storage Account and a Blob Container.
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS" // Locally Redundant Storage (cheapest)

  tags = {
    environment = "dev"
    project     = "terraform-demo"
  }
}

// Create multiple storage containers using for_each
resource "azurerm_storage_container" "containers" {
  for_each = var.container_definitions
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = each.value.container_access_type
}
