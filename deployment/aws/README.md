# AWS Deployment - Coffee Quality Inspection API

This directory contains Terraform configuration files to deploy the Coffee Bean Defect Detection API on AWS using ECS Fargate.

## 📋 Architecture Overview

The deployment includes:

- **ECR (Elastic Container Registry)**: Docker image repository
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer (ALB)**: Request routing and load balancing
- **CloudWatch**: Logging and monitoring
- **VPC & Security Groups**: Networking and security
- **Auto Scaling**: Automatic scaling based on CPU/memory metrics
- **S3 Bucket**: Model storage (optional, for larger deployments)

## 🚀 Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** (>= 1.0)
3. **AWS CLI** configured with credentials
4. **Docker** installed locally

```bash
# Verify installations
terraform version
aws --version
docker --version
```

## 📂 File Structure

```
aws/
├── main.tf              # Main infrastructure configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values (create this)
├── iam.tf               # IAM roles and policies
├── ecr.tf               # ECR repository setup
├── ecs.tf               # ECS cluster and services
├── alb.tf               # Application Load Balancer
├── networking.tf        # VPC and security groups
├── autoscaling.tf       # Auto scaling configuration
├── cloudwatch.tf        # Monitoring and logging
├── versions.tf          # Terraform and provider versions
└── README.md            # This file
```

## 🔧 Configuration Steps

### 1. Create `terraform.tfvars`

Copy and customize the following values:

```hcl
# terraform.tfvars
aws_region             = "us-east-1"
app_name               = "coffee-prediction"
environment            = "production"
container_port         = 9696
container_image_tag    = "latest"
container_cpu          = 256    # 256 (.25 vCPU), 512, 1024, 2048, 4096
container_memory       = 512    # 512 MB to 30 GB (depends on cpu)
desired_task_count     = 2
min_task_count         = 1
max_task_count         = 4

# Auto-scaling thresholds
target_cpu_percentage   = 70
target_memory_percentage = 80

# VPC Configuration
vpc_cidr               = "10.0.0.0/16"
availability_zones    = ["us-east-1a", "us-east-1b"]

# Tagging
tags = {
  Project     = "coffee-quality-inspection"
  Environment = "production"
  ManagedBy   = "terraform"
}
```

### 2. Initialize Terraform

```bash
cd deployment/aws
terraform init
```

### 3. Build and Push Docker Image

```bash
# Build the Docker image
docker build -t coffee-predictor:latest -f ../../deployment/flask/Dockerfile ../../

# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Tag the image
docker tag coffee-predictor:latest <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/coffee-prediction:latest

# Push to ECR
docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/coffee-prediction:latest
```

### 4. Plan and Apply Terraform

```bash
# Review the infrastructure plan
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan

# Save outputs
terraform output > outputs.json
```

## 📊 Available Terraform Commands

```bash
# View current state
terraform show

# List resources
terraform state list

# View specific resource
terraform state show aws_ecs_service.coffee_api

# Destroy infrastructure (WARNING: This will delete resources)
terraform destroy
```

## 🌐 Accessing the API

Once deployed, you can access the API through the Application Load Balancer:

```bash
# Get the ALB DNS name
terraform output -raw alb_dns_name

# Example API calls
export API_URL=$(terraform output -raw alb_dns_name)

# Health check
curl http://$API_URL/health

# Make prediction
curl -X POST -F "file=@/path/to/coffee/image.jpg" http://$API_URL/predict
```

## 📈 Monitoring

Access CloudWatch metrics and logs:

```bash
# View ECS service metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=coffee-prediction-service Name=ClusterName,Value=coffee-prediction-cluster \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 300 \
  --statistics Average

# View container logs
aws logs tail /ecs/coffee-prediction --follow
```

## 🔐 Security Considerations

1. **Secrets Management**: Store sensitive data in AWS Secrets Manager or Parameter Store
2. **IAM Roles**: Uses least-privilege IAM policies
3. **Security Groups**: Restricts inbound traffic to ALB only
4. **ECR Access**: Use IAM roles for ECS tasks to pull images
5. **HTTPS**: Configure ACM certificate and update ALB listener for HTTPS
6. **VPC**: Resources deployed in private subnets (optional enhancement)

## 💰 Cost Optimization

- **Fargate Spot**: Use Spot instances for non-critical workloads (add to ecs.tf)
- **Reserved Capacity**: Reserve capacity for predictable workloads
- **Auto Scaling**: Automatically scale based on demand
- **Multi-AZ**: Ensure high availability across zones

## 🛠 Troubleshooting

### Services not starting?

```bash
# Check task logs
aws ecs describe-tasks --cluster coffee-prediction-cluster \
  --tasks $(aws ecs list-tasks --cluster coffee-prediction-cluster \
  --query 'taskArns[0]' --output text) --query 'tasks[0].containers[0].lastStatus'

# View detailed logs
aws logs tail /ecs/coffee-prediction --follow
```

### Image not found in ECR?

```bash
# Verify image exists
aws ecr describe-images --repository-name coffee-prediction

# Check ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
```

### ALB health checks failing?

```bash
# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
  --names coffee-prediction-tg --query 'TargetGroups[0].TargetGroupArn' \
  --output text)
```

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Flask on AWS](https://aws.amazon.com/blogs/containers/flask-docker-application-ecs/)

## 📝 Next Steps

1. Update `terraform.tfvars` with your AWS account details
2. Push Docker image to ECR
3. Run `terraform plan` to review infrastructure
4. Deploy with `terraform apply`
5. Monitor via CloudWatch

---

For questions or issues, refer to AWS documentation or Terraform registry.
