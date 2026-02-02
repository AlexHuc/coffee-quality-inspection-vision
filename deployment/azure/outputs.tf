output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the Azure Resource Group"
  value       = azurerm_resource_group.main.id
}

output "container_registry_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "Login server URL for Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "ID of the Storage Account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the Storage Account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan (if deployed)"
  value       = try(azurerm_service_plan.main[0].name, null)
}

output "app_service_name" {
  description = "Name of the App Service (if deployed)"
  value       = try(azurerm_linux_web_app.main[0].name, null)
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service (if deployed)"
  value       = try(azurerm_linux_web_app.main[0].default_hostname, null)
}

output "app_service_https_url" {
  description = "HTTPS URL of the App Service (if deployed)"
  value       = try("https://${azurerm_linux_web_app.main[0].default_hostname}", null)
}

output "container_group_name" {
  description = "Name of the Container Group (if deployed)"
  value       = try(azurerm_container_group.main[0].name, null)
}

output "container_group_fqdn" {
  description = "FQDN of the Container Group (if deployed)"
  value       = try(azurerm_container_group.main[0].fqdn, null)
}

output "application_gateway_public_ip" {
  description = "Public IP of the Application Gateway"
  value       = try(azurerm_public_ip.app_gateway[0].ip_address, null)
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = try(azurerm_application_insights.main[0].instrumentation_key, null)
  sensitive   = true
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = try(azurerm_key_vault.main[0].id, null)
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = try(azurerm_key_vault.main[0].vault_uri, null)
}

output "api_endpoint" {
  description = "API endpoint URL"
  value = var.deployment_type == "app-service" ? try("https://${azurerm_linux_web_app.main[0].default_hostname}", null) : try("http://${azurerm_container_group.main[0].fqdn}:${var.container_port}", null)
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value = var.deployment_type == "app-service" ? try("https://${azurerm_linux_web_app.main[0].default_hostname}/health", null) : try("http://${azurerm_container_group.main[0].fqdn}:${var.container_port}/health", null)
}

output "predict_endpoint" {
  description = "Prediction endpoint URL"
  value = var.deployment_type == "app-service" ? try("https://${azurerm_linux_web_app.main[0].default_hostname}/predict", null) : try("http://${azurerm_container_group.main[0].fqdn}:${var.container_port}/predict", null)
}

output "docker_push_command" {
  description = "Command to push Docker image to ACR"
  value       = "docker push ${azurerm_container_registry.main.login_server}/${var.app_name}:${var.container_image_tag}"
}

output "deployment_type" {
  description = "Type of deployment used"
  value       = var.deployment_type
}
