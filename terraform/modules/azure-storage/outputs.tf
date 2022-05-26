output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "The name of the generated storage account"
}

output "storage_account_location" {
  value       = var.location
  description = "The location of the generated storage account"
}

output "resource_group_name" {
  value       = var.resource_group_name
  description = "The name of the generated resource group"
}
output "containers" {
  value       = var.containers
  description = "The name of the containers created"
}

output "subscription_id" {
  value       = var.subscription_id
  description = "Subscription id where the storage account is"
}
