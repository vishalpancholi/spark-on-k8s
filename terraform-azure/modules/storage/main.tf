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

// Create a Blob Container within the Storage Account
resource "azurerm_storage_container" "main" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private" // Private access by default
}

