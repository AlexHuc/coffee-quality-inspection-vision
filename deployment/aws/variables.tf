variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

variable "container_cpu" {
  description = "ECS task CPU units (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.container_cpu)
    error_message = "Valid CPU values are 256, 512, 1024, 2048, or 4096."
  }
}

variable "container_memory" {
  description = "ECS task memory in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.container_memory >= 512 && var.container_memory <= 30720
    error_message = "Memory must be between 512 MB and 30 GB."
  }
}

variable "container_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_task_count >= 1 && var.desired_task_count <= 10
    error_message = "Desired task count must be between 1 and 10."
  }
}

variable "min_task_count" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "max_task_count" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 4
}

variable "target_cpu_percentage" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 70

  validation {
    condition     = var.target_cpu_percentage > 0 && var.target_cpu_percentage <= 100
    error_message = "Target CPU percentage must be between 1 and 100."
  }
}

variable "target_memory_percentage" {
  description = "Target memory utilization percentage for auto-scaling"
  type        = number
  default     = 80

  validation {
    condition     = var.target_memory_percentage > 0 && var.target_memory_percentage <= 100
    error_message = "Target memory percentage must be between 1 and 100."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "coffee-quality-inspection"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period."
  }
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 120
    error_message = "Health check timeout must be between 2 and 120 seconds."
  }
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for ECS tasks"
  type        = bool
  default     = true
}
