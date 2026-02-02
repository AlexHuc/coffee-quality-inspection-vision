# ECR Repository for Docker images
resource "aws_ecr_repository" "coffee_prediction" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.app_name}-repo"
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "coffee_prediction" {
  repository = aws_ecr_repository.coffee_prediction.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus       = "any"
          countType       = "imageCountMoreThan"
          countNumber     = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url_detailed" {
  description = "Full ECR repository URL for pushing images"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.coffee_prediction.name}"
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  sensitive   = true
}
