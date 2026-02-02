# GCP Deployment - Coffee Quality Inspection API

This directory contains Terraform configuration files to deploy the Coffee Bean Defect Detection API on Google Cloud Platform (GCP) using Cloud Run.

![GCP](../../imgs/GCP.png)

## 📋 Architecture Overview

The deployment includes:

- **Artifact Registry**: Docker image repository
- **Cloud Run**: Serverless container orchestration with automatic scaling
- **Cloud Load Balancing**: Global HTTPS load balancer
- **Cloud Storage**: Model and artifact storage
- **Cloud Logging**: Centralized logging
- **Cloud Monitoring**: Metrics and alerting
- **VPC Network**: Network configuration and firewall rules
- **Cloud IAM**: Service accounts and permissions

## 🚀 Prerequisites

1. **GCP Account** with a project
2. **Terraform** (>= 1.0)
3. **Google Cloud SDK** (`gcloud` CLI) installed and configured
4. **Docker** installed locally

```bash
# Verify installations
terraform version
gcloud --version
docker --version

# Authenticate with GCP
gcloud auth application-default login
gcloud auth configure-docker us-central1-docker.pkg.dev  # Replace with your region
```

## 📂 File Structure

```
gcp/
├── main.tf                  # Main infrastructure configuration
├── variables.tf             # Variable definitions
├── outputs.tf               # Output values
├── terraform.tfvars         # Variable values (create this)
├── versions.tf              # Terraform and provider versions
├── cloud-run.tf             # Cloud Run service
├── artifact-registry.tf     # Docker image repository
├── iam.tf                   # IAM service accounts and roles
├── networking.tf            # VPC and firewall rules
├── storage.tf               # Cloud Storage buckets
├── monitoring.tf            # Cloud Monitoring and alerts
├── load-balancing.tf        # Cloud Load Balancer
└── README.md                # This file
```

## 🔧 Configuration Steps

### 1. Set GCP Project

```bash
# Set your project ID
export GCP_PROJECT_ID="your-project-id"
gcloud config set project $GCP_PROJECT_ID
```

### 2. Enable Required APIs

```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  container.googleapis.com \
  compute.googleapis.com \
  cloudbuild.googleapis.com \
  storage.googleapis.com \
  cloudlogging.googleapis.com \
  monitoring.googleapis.com \
  servicenetworking.googleapis.com
```

### 3. Create `terraform.tfvars`

Copy and customize the following values:

```hcl
# terraform.tfvars
gcp_project_id      = "your-project-id"
gcp_region          = "us-central1"
app_name            = "coffee-prediction"
environment         = "production"

# Cloud Run Configuration
container_port      = 9696
container_cpu       = "1"          # 0.25, 0.5, 1, 2, 4
container_memory    = "512Mi"      # 128Mi to 8Gi
container_timeout   = 300

# Scaling
min_instances       = 0
max_instances       = 10
concurrency         = 80

# Network
enable_vpc_connector = false  # Set true to use VPC connector
vpc_connector_name   = null

# Storage
enable_model_bucket = true
model_bucket_prefix = "gs://coffee-models"

# Monitoring
enable_monitoring   = true
log_retention_days  = 30
alert_threshold_cpu = 0.8

# Tags
labels = {
  project     = "coffee-quality-inspection"
  environment = "production"
  managed-by  = "terraform"
}
```

### 4. Initialize Terraform

```bash
cd deployment/gcp
terraform init
```

### 5. Build and Push Docker Image

```bash
# Set variables
export GCP_REGION="us-central1"
export GCP_PROJECT_ID="your-project-id"
export IMAGE_REPO="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/coffee-prediction"

# Create Artifact Registry repository (if not created by Terraform)
gcloud artifacts repositories create coffee-prediction \
  --repository-format=docker \
  --location=$GCP_REGION

# Build the Docker image
docker build -t coffee-predictor:latest -f ../../deployment/flask/Dockerfile ../../

# Configure Docker authentication
gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev

# Tag the image
docker tag coffee-predictor:latest ${IMAGE_REPO}/coffee-prediction:latest

# Push to Artifact Registry
docker push ${IMAGE_REPO}/coffee-prediction:latest
```

### 6. Plan and Apply Terraform

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
terraform state show google_cloud_run_service.api

# Destroy infrastructure (WARNING: This will delete resources)
terraform destroy
```

## 🌐 Accessing the API

Once deployed, you can access the API through the Cloud Run service URL:

```bash
# Get the service URL
SERVICE_URL=$(terraform output -raw cloud_run_service_url)

# Example API calls
# Health check
curl ${SERVICE_URL}/health

# Make prediction
curl -X POST -F "file=@/path/to/coffee/image.jpg" ${SERVICE_URL}/predict
```

## 📈 Monitoring

Access Cloud Monitoring and logging:

```bash
# View Cloud Run logs
gcloud logs read --limit 50 --service=cloud-run

# View specific service logs
gcloud logs read --service="cloud-run" \
  --resource="cloud_run_resource" \
  --limit 100

# Real-time log streaming
gcloud logs read --service="cloud-run" \
  --resource="cloud_run_resource" \
  --follow

# View metrics in Cloud Console
# Navigate to: Monitoring > Dashboards > Cloud Run
```

## 🔐 Security Considerations

1. **Service Accounts**: Uses dedicated service account with minimal permissions
2. **IAM Roles**: Least-privilege principle applied
3. **Cloud Run**: Only accessible through authenticated requests (can be changed)
4. **VPC Connector**: Optional integration for private connectivity
5. **Secrets Management**: Use Google Secret Manager for sensitive data
6. **HTTPS**: Cloud Run automatically provides HTTPS
7. **CORS**: Configurable for cross-origin requests

## 💰 Cost Optimization

- **Cloud Run**: Pay only for request processing time (no idle charges with min_instances=0)
- **Artifact Registry**: Storage charges for images
- **Cloud Storage**: Optional storage for models and artifacts
- **Cloud Logging**: Free tier includes 50GB/month
- **Cloud Monitoring**: Free tier for basic metrics and alerts

### Cost Estimation

For typical usage patterns:
- **100 requests/day** at 1 second each: ~$0.20/month
- **1,000 requests/day**: ~$2/month
- **10,000 requests/day**: ~$20/month

## 🛠 Troubleshooting

### Service not deploying?

```bash
# Check service status
gcloud run services describe coffee-prediction --region=us-central1

# View deployment logs
gcloud builds log $(gcloud builds list --limit=1 --format='value(id)')

# Check Cloud Run logs for errors
gcloud logging read --service=cloud-run --limit=50
```

### Image not found in Artifact Registry?

```bash
# List repositories
gcloud artifacts repositories list --location=us-central1

# List images in repository
gcloud artifacts docker images list us-central1-docker.pkg.dev/PROJECT_ID/coffee-prediction

# Check image push logs
gcloud builds log $(gcloud builds list --limit=1 --format='value(id)')
```

### Permission denied errors?

```bash
# Check service account permissions
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:*@iam.gserviceaccount.com"

# Grant necessary permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:SERVICE_ACCOUNT_EMAIL \
  --role=roles/run.invoker
```

### High latency or timeouts?

```bash
# Check Cloud Run metrics
gcloud monitoring read \
  --filter='resource.type="cloud_run_revision" AND metric.type="run.googleapis.com/request_latencies"' \
  --format=table

# Increase timeout or memory if needed
# Update variables.tf and reapply:
# container_cpu = "2"
# container_memory = "1Gi"
# container_timeout = 600
```

## 🚀 Deployment Workflow

### Initial Deployment

```bash
# 1. Set up project and enable APIs
export GCP_PROJECT_ID="your-project-id"
gcloud config set project $GCP_PROJECT_ID
gcloud services enable run.googleapis.com artifactregistry.googleapis.com

# 2. Create terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialize Terraform
terraform init

# 4. Build and push Docker image
# (See Build and Push Docker Image section)

# 5. Deploy
terraform plan -out=tfplan
terraform apply tfplan
```

### Updating the Application

```bash
# 1. Build and push new image with new tag
docker build -t coffee-predictor:v2 -f ../../deployment/flask/Dockerfile ../../
docker tag coffee-predictor:v2 ${IMAGE_REPO}/coffee-prediction:v2
docker push ${IMAGE_REPO}/coffee-prediction:v2

# 2. Update container_image_tag in terraform.tfvars
# container_image_tag = "v2"

# 3. Reapply Terraform
terraform plan -out=tfplan
terraform apply tfplan
```

### Rollback

```bash
# Cloud Run automatically maintains previous revisions
# Rollback to previous revision via console or CLI:
gcloud run deploy coffee-prediction \
  --region=us-central1 \
  --image=us-central1-docker.pkg.dev/PROJECT_ID/coffee-prediction/coffee-prediction:previous-tag
```

## 🔍 Advanced Configuration

### Using VPC Connector for Private Networking

```hcl
# In terraform.tfvars
enable_vpc_connector = true

# This requires additional configuration in networking.tf
# The connector allows Cloud Run to access internal resources
```

### Custom Domain with Cloud Domains

```bash
# Map custom domain to Cloud Run service
gcloud run services update coffee-prediction \
  --region=us-central1 \
  --update-env-vars DOMAIN=api.yourdomain.com
```

### Scheduled Batch Processing with Cloud Tasks

See `monitoring.tf` for optional Cloud Scheduler integration for batch predictions.

## 📚 Additional Resources

- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud Run Deployment Guide](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)
- [GCP Best Practices](https://cloud.google.com/architecture/best-practices)

## 📝 Next Steps

1. Set up GCP project and enable APIs
2. Update `terraform.tfvars` with your configuration
3. Build and push Docker image to Artifact Registry
4. Run `terraform plan` to review infrastructure
5. Deploy with `terraform apply`
6. Monitor via Cloud Logging and Cloud Monitoring

## 💡 Tips

- **Cold Starts**: Use `min_instances > 0` to reduce cold start latency
- **Model Size**: Store large models in Cloud Storage and download on startup
- **Concurrency**: Adjust based on your workload and instance type
- **Regions**: Choose region closest to your users for lower latency
- **Budget Alerts**: Set up billing alerts in GCP Console

---

For questions or issues, refer to [GCP Documentation](https://cloud.google.com/docs) or [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).
