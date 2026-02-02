# Application Insights
resource "azurerm_application_insights" "main" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.app_name}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  retention_in_days   = var.log_retention_days

  tags = local.tags
}

# Azure Monitor Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.app_name}-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = local.tags
}

# App Service Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  count              = var.enable_monitoring && var.deployment_type == "app-service" ? 1 : 0
  name               = "${var.app_name}-diagnostics"
  target_resource_id = azurerm_linux_web_app.main[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Metric Alert - High CPU Usage
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.app_name}-high-cpu"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = var.deployment_type == "app-service" ? [azurerm_service_plan.main[0].id] : (var.deployment_type == "container-instances" ? [azurerm_container_group.main[0].id] : [])
  description         = "Alert when CPU usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_name       = "CpuPercentage"
    metric_namespace  = "Microsoft.Web/serverfarms"
    aggregation       = "Average"
    operator          = "GreaterThan"
    threshold         = 80
  }
}

# Metric Alert - High Memory Usage
resource "azurerm_monitor_metric_alert" "memory_alert" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.app_name}-high-memory"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = var.deployment_type == "app-service" ? [azurerm_service_plan.main[0].id] : (var.deployment_type == "container-instances" ? [azurerm_container_group.main[0].id] : [])
  description         = "Alert when memory usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_name       = "MemoryPercentage"
    metric_namespace  = "Microsoft.Web/serverfarms"
    aggregation       = "Average"
    operator          = "GreaterThan"
    threshold         = 80
  }
}

# Action Group for Alerts (optional - add email/webhook)
resource "azurerm_monitor_action_group" "main" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.app_name}-action-group"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "coffeeapi"

  tags = local.tags
}
