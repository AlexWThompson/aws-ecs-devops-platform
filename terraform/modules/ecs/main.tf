module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.0" # Always pin to a major version to prevent breaking changes

  cluster_name = "aws-devops-ecs-cluster"

  # Enable CloudWatch Container Insights for cluster metrics
  cluster_settings = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  # Allocate Fargate capacity providers to the cluster
  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # Define the default strategy for distributed scaling
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 1 # Keep at least 1 reliable task running on standard Fargate
    }
    FARGATE_SPOT = {
      weight = 50 # Distribute remaining tasks evenly to save costs
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.0"

  name        = "aws-devops-ecs-service"
  cluster_arn = module.ecs_cluster.arn

  launch_type = "FARGATE"

  cpu    = 256
  memory = 512

  task_exec_iam_role_arn = var.ecs_task_execution_role_arn
  task_iam_role_arn      = var.ecs_task_role_arn

  container_definitions = {
    dashboard = {
      image = var.ecr_repository_url

      essential = true

      port_mappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}