# AWS Enterprise Infrastructure & CI/CD Platform

Production-style AWS infrastructure and CI/CD platform built with **Terraform, Docker, Amazon ECS Fargate, Amazon ECR, GitHub Actions, and AWS IAM OIDC**.

The goal of this project is to demonstrate how a containerized application can be deployed, monitored, scaled, and managed using Infrastructure as Code and automated CI/CD practices.

---

## Architecture

```text
                         GitHub
                            |
                            | Push / Pull Request
                            v
                   +-----------------+
                   | GitHub Actions  |
                   +--------+--------+
                            |
                +-----------+------------+              +------------------*
                |           |            |              |                  |
             Testing   Security Scan  Terraform ---------    S3 Bucket     |
                |           |          Plan/Apply       |  for state files |
                +-----------+------------+              +------------------+
                            |
                       AWS OIDC
                            |
                            v
                    +--------------+
                    |     AWS      |
                    +------+-------+
                           |
             +-------------+-------------+
             |                           |
             v                           v
       Amazon ECR                 AWS Infrastructure
             |                           |
             |                    +------+------+
             |                    |             |
             |                    v             v
             |                   VPC           IAM
             |                    |
             |                    +----------------+
             |                    |                |
             |                    v                v 
             |              Public Subnets  Private Subnets
             |                    |                |
             |                    v                |
             |                   ALB               |
             |                    |                |
             |                    v                |
             +------------> ECS Fargate <----------+
                                |
                         +------+------+
                         |             |
                      Task 1        Task 2
                         |             |
                         +------+------+
                                |
                         CloudWatch Logs
                                |
                         CloudWatch Alarms
                                |
                                v
                               SNS
```

---

## Project Overview

This project implements a production-style AWS environment for deploying a containerized web application.

The infrastructure is managed entirely through **Terraform**, while application delivery is automated through **GitHub Actions**.

The application is packaged as a Docker container and deployed to **Amazon ECS using AWS Fargate**. An **Application Load Balancer** provides external access to the application while ECS tasks run in private subnets.

The project also demonstrates:

* Infrastructure as Code
* CI/CD automation
* Containerization
* AWS IAM
* GitHub Actions OIDC authentication
* Container image management
* Application monitoring
* ECS autoscaling
* Health checks
* Security scanning

---

## Technologies

### AWS

* Amazon VPC
* Amazon ECS
* AWS Fargate
* Amazon ECR
* Application Load Balancer
* AWS IAM
* Amazon CloudWatch
* Amazon SNS
* Amazon S3

### DevOps

* Terraform
* Docker
* GitHub Actions
* Git

---

## Application

The application is a small Dockerized web application designed to provide a simple view into the deployed infrastructure.

Example:

```text
AWS DevOps Infrastructure Dashboard

Application: ECS Dashboard
Version: <<version>>
Environment: Development
Status: Healthy
```

The application exposes a health endpoint:

```text
/health
```

The health endpoint is used by the ECS container health check and Application Load Balancer.

The application also exposes a cpu-test endpoint:

```test
"status": "completed"
```

This was used to artificially apply CPU load to trigger ECS auto scaling using CPUUtilization as the metric

The application itself is intentionally simple. The primary purpose of this project is to demonstrate the infrastructure, automation, security, and deployment platform surrounding the application.

---

## Infrastructure

The AWS infrastructure is provisioned using Terraform.

The environment consists of:

### Networking

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Security groups

### Compute

* ECS cluster
* ECS Fargate service
* ECS task definitions
* Multiple running tasks
* ECS service autoscaling

### Load Balancing

* Application Load Balancer
* Target group
* HTTP listener
* Health checks

### Container Registry

* Amazon ECR repository
* Image scanning
* Immutable image tags

### Monitoring

* CloudWatch Logs
* CloudWatch metrics
* CloudWatch alarms
* SNS notifications

### Security

* IAM roles
* GitHub Actions OIDC
* Private ECS workloads
* Container image scanning

---

## Repository Structure

```text
aws-ecs-devops-platform/
|
+-- app/
|   +-- templates/
|   +-- app.py
|
+-- terraform/
|   |
|   +-- modules/
|   |   +-- alb/
|   |   +-- ecr/
|   |   +-- ecs/
|   |   +-- iam/
|   |   +-- monitoring/
|   |   +-- sg/
|   |   +-- vpc/
|
|
+-- .github/
|   +-- workflows/
|       +-- deploy.yml
|
|
+-- Dockerfile
+-- requirements.txt
+-- .gitignore
+-- README.md
```

---

## Infrastructure as Code

Terraform is used to create and manage AWS resources.

Terraform modules are used to separate infrastructure components and allow resources to be reused across environments.

Example modules:

```text
modules/
+-- vpc
+-- iam
+-- ecr
+-- ecs
+-- alb
+-- monitoring
+-- sg
```

Terraform state is stored remotely in Amazon S3.

The infrastructure can be created with:

```bash
terraform init
terraform fmt -check
terraform plan
terraform apply
```

Infrastructure changes are validated through the CI/CD pipeline before being applied.

---

## CI/CD Pipeline

GitHub Actions is used to automate application and infrastructure deployment.

---

## Application Deployment

Application deployment follows this workflow:

```text
Git Push
   |
   v
GitHub Actions
   |
   +-- Build Docker Image
   |
   +-- Scan Image
   |
   +-- Authenticate to AWS
   |
   +-- Push Image to ECR
   |
   +-- Deploy to ECS
          |
          v
      ECS Fargate
```

Docker images are tagged using the application version and/or Git commit SHA.

Example:

```text
ecs-dashboard:1.0.0
ecs-dashboard:a83f921
```

This allows deployments to reference specific, immutable container versions.

---

## AWS Authentication

GitHub Actions authenticates to AWS using **OpenID Connect (OIDC)**.

Long-lived AWS access keys are not stored in GitHub.

The authentication flow is:

```text
GitHub Actions
      |
      | OIDC Token
      v
AWS IAM OIDC Provider
      |
      v
GitHub Actions IAM Role
      |
      v
Temporary AWS Credentials
```

The IAM role is restricted to the specific GitHub repository and required AWS permissions.

---

## ECS Architecture

The application runs using Amazon ECS with AWS Fargate.

The ECS service maintains multiple running tasks:

```text
ECS Service
|
+-- Fargate Task
|   +-- Docker Container
|
+-- Fargate Task
    +-- Docker Container
```

Tasks run in private subnets and are accessed through the Application Load Balancer.

The ALB performs health checks against the application.

If an unhealthy task is detected, ECS can automatically replace it.

---

## Auto Scaling

ECS Service Auto Scaling dynamically adjusts the number of running tasks based on application load.

Example configuration:

```text
Target Tracking : Maintain target
ECSServiceAverageCPUUtilization (75%)
ECSServiceAverageMemoryUtilization (75%)
```

During increased CPU utilization:

```text
2 Tasks
   |
   v
High CPU Utilization
   |
   v
ECS Auto Scaling
   |
   v
4 Tasks
```

When demand decreases, the service scales back toward the desired capacity.

---

## Monitoring

Application and container logs are sent to Amazon CloudWatch Logs.

CloudWatch is used to monitor:

* ECS CPU utilization
* ECS memory utilization
* Running task count
* ALB health
* Application logs
* Deployment events

CloudWatch alarms are configured for conditions such as:

```text
CPU utilization > threshold
Running tasks < desired count
Unhealthy ALB targets
```

SNS is used to send notifications when configured alarms are triggered.

---

## Security

Security is incorporated throughout the infrastructure.

### IAM

IAM roles follow least-privilege principles wherever practical.

Separate roles are used for:

* GitHub Actions
* ECS task execution
* ECS application tasks

### Networking

ECS tasks run in private subnets.

The Application Load Balancer is the public entry point.

```text
Internet
   |
   v
ALB
   |
   v
Private ECS Tasks
```

### Container Security

Container images are scanned for vulnerabilities before deployment.

Images use immutable version tags rather than relying solely on `latest`.

---

## Failure Testing

The platform is tested by intentionally introducing failures.

### ECS Task Failure

A running ECS task is stopped manually.

Expected behavior:

```text
Task stopped
    |
    v
ECS detects unhealthy service capacity
    |
    v
Replacement task launched
    |
    v
ALB routes traffic to healthy task
```

### Failed Deployment

A test deployment can be configured to fail health checks.

The deployment process is monitored to verify that the existing healthy application remains available.

### Infrastructure Recovery

The environment can be destroyed and recreated using Terraform:

```bash
terraform destroy
```

followed by:

```bash
terraform apply
```

The goal is to demonstrate that the environment is reproducible and does not depend on undocumented manual configuration.

---

## Deployment

### Prerequisites

The following tools are required:

* AWS account
* AWS CLI
* Terraform
* Docker
* Git
* GitHub account

AWS resources required for the project are provisioned through Terraform where practical.

---

### Local Application

Build the Docker image:

```bash
docker build -t ecs-dashboard .
```

Run locally:

```bash
docker run -p 8080:8080 ecs-dashboard
```

Test:

```text
http://localhost:8080
```

Health check:

```text
http://localhost:8080/health
```

---

## Terraform Deployment

Initialize Terraform:

```bash
terraform init
```

Format Terraform:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

Create a plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

---

## Project Goals

This project was created to demonstrate practical experience with modern AWS DevOps practices, including:

* Infrastructure as Code
* AWS cloud architecture
* Containerized application deployment
* CI/CD
* Infrastructure automation
* AWS IAM
* Secure authentication
* Monitoring and observability
* Application scalability
* Failure recovery
* Reproducible infrastructure

The project intentionally combines infrastructure engineering concepts with modern cloud-native deployment practices.

---

## Author

**Alex Thompson**

Infrastructure / DevOps Engineer

Technologies demonstrated in this project:

**AWS • Terraform • Docker • ECS • Fargate • ECR • GitHub Actions • IAM • CloudWatch • CI/CD**
