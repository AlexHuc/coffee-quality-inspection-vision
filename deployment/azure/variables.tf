variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_region" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus", "westus", "westus2", "eastus2", "northeurope", "westeurope", "southeastasia", "eastasia"], var.azure_region)
    error_message = "Region must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "coffee-prediction-rg"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "coffee-prediction"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 9696
}

variable "container_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "container_cpu" {
  description = "CPU cores for container"
  type        = number
  default     = 1

  validation {
    condition     = var.container_cpu > 0 && var.container_cpu <= 8
    error_message = "CPU must be between 0.25 and 8 cores."
  }
}

variable "container_memory" {
  description = "Memory in GB for container"
  type        = number
  default     = 1.5

  validation {
    condition     = var.container_memory > 0 && var.container_memory <= 16
    error_message = "Memory must be between 0.5 and 16 GB."
  }
}

variable "deployment_type" {
  description = "Deployment type: app-service or container-instances"
  type        = string
  default     = "app-service"

  validation {
    condition     = contains(["app-service", "container-instances"], var.deployment_type)
    error_message = "Deployment type must be app-service or container-instances."
  }
}

variable "app_service_tier" {
  description = "App Service pricing tier (B1, B2, B3, S1, S2, S3, P1V2, P2V2, P3V2)"
  type        = string
  default     = "B1"

  validation {
    condition     = contains(["B1", "B2", "B3", "S1", "S2", "S3", "P1V2", "P2V2", "P3V2"], var.app_service_tier)
    error_message = "App Service tier must be a valid tier."
  }
}

variable "app_service_instances" {
  description = "Number of App Service instances"
  type        = number
  default     = 2

  validation {
    condition     = var.app_service_instances >= 1 && var.app_service_instances <= 30
    error_message = "App Service instances must be between 1 and 30."
  }
}

variable "container_instances_count" {
  description = "Number of Container Instances"
  type        = number
  default     = 2

  validation {
    condition     = var.container_instances_count >= 1 && var.container_instances_count <= 10
    error_message = "Container Instances count must be between 1 and 10."
  }
}

variable "restart_policy" {
  description = "Container restart policy (Always, OnFailure, Never)"
  type        = string
  default     = "OnFailure"

  validation {
    condition     = contains(["Always", "OnFailure", "Never"], var.restart_policy)
    error_message = "Restart policy must be Always, OnFailure, or Never."
  }
}

variable "enable_blob_storage" {
  description = "Enable Azure Blob Storage for models"
  type        = bool
  default     = true
}

variable "storage_sku" {
  description = "Storage account SKU (Standard_LRS, Standard_GRS, Standard_RAGRS, Premium_LRS)"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "Standard_GRS", "Standard_RAGRS", "Premium_LRS"], var.storage_sku)
    error_message = "Storage SKU must be a valid Azure storage SKU."
  }
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor and Application Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 730
    error_message = "Log retention must be between 7 and 730 days."
  }
}

variable "enable_key_vault" {
  description = "Enable Azure Key Vault"
  type        = bool
  default     = true
}

variable "enable_soft_delete" {
  description = "Enable soft delete for Key Vault"
  type        = bool
  default     = true
}

variable "enable_app_gateway" {
  description = "Enable Application Gateway for load balancing"
  type        = bool
  default     = true
}

variable "app_gateway_capacity" {
  description = "Application Gateway capacity"
  type        = number
  default     = 2

  validation {
    condition     = var.app_gateway_capacity >= 1 && var.app_gateway_capacity <= 32
    error_message = "App Gateway capacity must be between 1 and 32."
  }
}

variable "container_registry_sku" {
  description = "Container Registry SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.container_registry_sku)
    error_message = "Container Registry SKU must be Basic, Standard, or Premium."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    project     = "coffee-quality-inspection"
    environment = "production"
    managed-by  = "terraform"
  }
}
