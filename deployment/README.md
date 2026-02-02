# Deployment

This directory contains all resources needed to deploy the **Coffee Quality Inspection Vision models** across multiple platforms: local Docker, Kubernetes, and major cloud providers.

## Structure

### `flask/`
This folder provides a lightweight web service exposing the prediction model through a REST API.

- **Dockerfile** – Builds a Docker image for the Flask service  
- **Pipfile / Pipfile.lock** – Dependency management using Pipenv  
- **predict.py** – Flask app serving prediction endpoints  
- **predict_test.ipynb** – Notebook for testing the API  
- **README.md** – Instructions for running the Flask service locally or via Docker

### `kubernetes/`
This folder contains the configuration required to run the model in a Kubernetes cluster.

- **deployment.yaml** – Kubernetes manifests for the API  
- **deploy.sh** – Shell script to apply the manifests and manage the deployment  
- **README.md** – Guide for deploying using Minikube or a cloud Kubernetes cluster

### `aws/`
This folder contains Terraform infrastructure-as-code for AWS deployment.

- **versions.tf** – Terraform provider configuration  
- **main.tf** – Main AWS infrastructure setup  
- **variables.tf** – Input variables for customization  
- **outputs.tf** – Output values (ALB DNS, service endpoints)  
- **networking.tf** – VPC, subnets, and security groups  
- **ecr.tf** – Elastic Container Registry configuration  
- **ecs.tf** – ECS Fargate cluster and task definitions  
- **alb.tf** – Application Load Balancer setup  
- **cloudwatch.tf** – CloudWatch monitoring and alarms  
- **autoscaling.tf** – Auto-scaling policies  
- **iam.tf** – IAM roles and permissions  
- **terraform.tfvars.example** – Configuration template  
- **README.md** – Complete AWS deployment guide

### `gcp/`
This folder contains Terraform infrastructure-as-code for Google Cloud Platform deployment.

- **versions.tf** – Terraform provider configuration  
- **main.tf** – Main GCP infrastructure setup  
- **variables.tf** – Input variables for customization  
- **outputs.tf** – Output values (Cloud Run URL, endpoints)  
- **artifact-registry.tf** – Container image registry  
- **cloud-run.tf** – Cloud Run serverless service  
- **storage.tf** – Cloud Storage buckets  
- **networking.tf** – VPC and firewall rules  
- **monitoring.tf** – Cloud Logging and Cloud Monitoring  
- **load-balancing.tf** – Optional global load balancer  
- **iam.tf** – Service accounts and IAM bindings  
- **terraform.tfvars.example** – Configuration template  
- **README.md** – Complete GCP deployment guide

### `azure/`
This folder contains Terraform infrastructure-as-code for Microsoft Azure deployment.

- **versions.tf** – Terraform provider configuration  
- **main.tf** – Main Azure infrastructure setup  
- **variables.tf** – Input variables for customization  
- **outputs.tf** – Output values (App Service URL, endpoints)  
- **resource-group.tf** – Azure Resource Group  
- **container-registry.tf** – Azure Container Registry (ACR)  
- **app-service.tf** – App Service Plan and Web App with auto-scaling  
- **container-instances.tf** – Alternative serverless deployment  
- **app-gateway.tf** – Application Gateway for load balancing  
- **monitoring.tf** – Application Insights and Log Analytics  
- **key-vault.tf** – Azure Key Vault for secrets management  
- **storage.tf** – Storage accounts and containers  
- **iam.tf** – Managed identities and RBAC assignments  
- **terraform.tfvars.example** – Configuration template  
- **README.md** – Complete Azure deployment guide

---

## Deployment Options Comparison

| Platform | Setup | Scaling | Cost/Month | Best For |
|----------|-------|---------|-----------|----------|
| **Flask Local** | 1 min | Manual | $0 | Development |
| **Docker** | 1 min | Manual | $0 | CI/CD, Testing |
| **Kubernetes** | 3 min | Auto | $0 | Production, Self-managed |
| **AWS** | 20 min | Auto | $50–150 | Enterprise, Large scale |
| **GCP** | 15 min | Auto | $2–10 | Startups, Cost-conscious |
| **Azure** | 20 min | Auto | $15–50 | Enterprise Microsoft shops |

---

All deployment options package the same trained model, allowing you to run inference in local, containerized, or distributed cloud environments.