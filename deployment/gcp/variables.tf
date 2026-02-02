variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1", "europe-west1", "asia-east1", "asia-southeast1"], var.gcp_region)
    error_message = "Region must be a valid GCP region."
  }
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
  description = "Cloud Run CPU allocation (0.25, 0.5, 1, 2, 4)"
  type        = string
  default     = "1"

  validation {
    condition     = contains(["0.25", "0.5", "1", "2", "4"], var.container_cpu)
    error_message = "CPU must be 0.25, 0.5, 1, 2, or 4."
  }
}

variable "container_memory" {
  description = "Cloud Run memory allocation (e.g., 128Mi, 256Mi, 512Mi, 1Gi, 2Gi, 4Gi, 8Gi)"
  type        = string
  default     = "512Mi"

  validation {
    condition = contains(
      ["128Mi", "256Mi", "512Mi", "1Gi", "2Gi", "4Gi", "8Gi"],
      var.container_memory
    )
    error_message = "Memory must be a valid Cloud Run memory size."
  }
}

variable "container_timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.container_timeout >= 1 && var.container_timeout <= 3600
    error_message = "Timeout must be between 1 and 3600 seconds."
  }
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances >= 0 && var.min_instances <= 1000
    error_message = "Min instances must be between 0 and 1000."
  }
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 1000
    error_message = "Max instances must be between 1 and 1000."
  }
}

variable "concurrency" {
  description = "Number of concurrent requests per instance"
  type        = number
  default     = 80

  validation {
    condition     = var.concurrency >= 1 && var.concurrency <= 1000
    error_message = "Concurrency must be between 1 and 1000."
  }
}

variable "enable_vpc_connector" {
  description = "Enable VPC connector for private networking"
  type        = bool
  default     = false
}

variable "vpc_connector_name" {
  description = "VPC connector name (required if enable_vpc_connector is true)"
  type        = string
  default     = null
}

variable "enable_model_bucket" {
  description = "Enable Cloud Storage bucket for model storage"
  type        = bool
  default     = true
}

variable "model_bucket_prefix" {
  description = "Prefix for model bucket name"
  type        = string
  default     = "gs://coffee-models"
}

variable "enable_monitoring" {
  description = "Enable Cloud Monitoring and alerting"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Cloud Logging retention in days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 3650
    error_message = "Log retention must be between 1 and 3650 days."
  }
}

variable "alert_threshold_cpu" {
  description = "CPU utilization threshold for alerts (0-1)"
  type        = number
  default     = 0.8

  validation {
    condition     = var.alert_threshold_cpu > 0 && var.alert_threshold_cpu <= 1
    error_message = "Alert threshold must be between 0 and 1."
  }
}

variable "enable_public_access" {
  description = "Allow public access to Cloud Run service"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    project     = "coffee-quality-inspection"
    environment = "production"
    managed-by  = "terraform"
  }
}

variable "enable_load_balancer" {
  description = "Enable Cloud Load Balancer"
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "Custom domain name (optional)"
  type        = string
  default     = null
}
