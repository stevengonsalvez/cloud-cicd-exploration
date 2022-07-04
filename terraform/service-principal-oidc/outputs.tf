output "sp_application_id" {
  value       = azuread_service_principal.this.application_id
  description = "The service principal application id"
}

output "sp_password" {
  value       = azuread_application_password.this.value
  description = "The service principal password"
  sensitive   = true
}

output "sp_application_name" {
  value       = azuread_application.this.display_name
  description = "The name of the application"
}

output "sp_object_id" {
  value       = azuread_service_principal.this.object_id
  description = "Object ID for the service principal"
}

output "credential_id" {
  value = azuread_application_federated_identity_credential.main.id
}