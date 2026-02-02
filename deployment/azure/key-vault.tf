# Azure Key Vault
resource "azurerm_key_vault" "main" {
  count               = var.enable_key_vault ? 1 : 0
  name                = replace("${var.app_name}-kv", "-", "")
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enabled_for_disk_encryption   = true
  enabled_for_template_deployment = true
  purge_protection_enabled      = false
  soft_delete_retention_days    = var.enable_soft_delete ? 7 : null

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]

    storage_permissions = [
      "Get",
      "List",
      "Delete",
      "Set",
    ]
  }

  # Access policy for App Service (if deployed)
  dynamic "access_policy" {
    for_each = var.deployment_type == "app-service" ? [1] : []
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = azurerm_user_assigned_identity.app_service[0].principal_id

      secret_permissions = [
        "Get",
        "List",
      ]
    }
  }

  # Access policy for Container Group (if deployed)
  dynamic "access_policy" {
    for_each = var.deployment_type == "container-instances" ? [1] : []
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = azurerm_user_assigned_identity.container_group[0].principal_id

      secret_permissions = [
        "Get",
        "List",
      ]
    }
  }

  tags = local.tags
}

# Key Vault Secret - Container Registry Password
resource "azurerm_key_vault_secret" "acr_password" {
  count        = var.enable_key_vault ? 1 : 0
  name         = "acr-password"
  value        = azurerm_container_registry.main.admin_password
  key_vault_id = azurerm_key_vault.main[0].id
}

# Key Vault Secret - Storage Account Connection String
resource "azurerm_key_vault_secret" "storage_connection_string" {
  count        = var.enable_key_vault ? 1 : 0
  name         = "storage-connection-string"
  value        = azurerm_storage_account.main.primary_connection_string
  key_vault_id = azurerm_key_vault.main[0].id
}
