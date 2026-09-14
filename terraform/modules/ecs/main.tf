module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 6.0" # Always pin to a major version to prevent breaking changes

  name = "aws-devops-ecs-cluster"

  # Enable CloudWatch Container Insights for cluster metrics
  setting = [
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

  launch_type = "FARGATE"

  cpu    = 256
  memory = 512

  task_exec_iam_role_arn = var.ecs_task_execution_role_arn
  tasks_iam_role_arn     = var.ecs_task_role_arn

  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  container_definitions = {
    ecs-dashboard = {
      image = "${var.ecr_repository_url}:${var.image_tag}"

      essential = true

      port_mappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "dashboard"
    container_port   = 8080
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}