// Configures the Azure Resource Manager (AzureRM) provider.

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}