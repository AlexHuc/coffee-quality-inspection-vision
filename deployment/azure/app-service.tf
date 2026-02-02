# App Service Plan
resource "azurerm_service_plan" "main" {
  count               = var.deployment_type == "app-service" ? 1 : 0
  name                = "${var.app_name}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_tier

  tags = local.tags
}

# Linux Web App
resource "azurerm_linux_web_app" "main" {
  count               = var.deployment_type == "app-service" ? 1 : 0
  name                = var.app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main[0].id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_service[0].id]
  }

  site_config {
    container_registry_use_managed_identity = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.app_service[0].client_id

    application_stack {
      docker_image_name   = "${azurerm_container_registry.main.login_server}/${var.app_name}:${var.container_image_tag}"
      docker_registry_url = "https://${azurerm_container_registry.main.login_server}"
    }

    always_on = true
  }

  app_settings = {
    FLASK_ENV          = var.environment
    WEBSITES_PORT      = var.container_port
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
  }

  depends_on = [
    azurerm_role_assignment.acr_pull_app_service
  ]

  tags = local.tags
}

# App Service Auto Scale Setting
resource "azurerm_monitor_autoscale_setting" "app_service" {
  count               = var.deployment_type == "app-service" ? 1 : 0
  name                = "${var.app_name}-autoscale"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  target_resource_id  = azurerm_service_plan.main[0].id

  profile {
    name = "Scale based on CPU"

    capacity {
      default = var.app_service_instances
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main[0].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main[0].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }
}
