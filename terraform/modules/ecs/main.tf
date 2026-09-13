module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 6.0" # Always pin to a major version to prevent breaking changes

  cluster_name = "aws-devops-ecs-cluster"

  # Enable CloudWatch Container Insights for cluster metrics
  cluster_settings = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 6.0"

  name        = "aws-devops-ecs-service"
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  task_exec_iam_role_arn = var.ecs_task_execution_role_arn
  tasks_iam_role_arn     = var.ecs_task_role_arn

  capacity_provider_strategy = {
    FARGATE = {
      weight = 1
      base   = 1
    }
  }

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