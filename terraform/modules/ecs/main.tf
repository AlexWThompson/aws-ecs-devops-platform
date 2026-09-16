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

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  }

  load_balancer = {
  service = {
    target_group_arn = var.target_group_arn
    container_name = "ecs-dashboard"
    container_port = 8080
    }
  }

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${module.ecs_cluster.name}/${module.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_cpu_target

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}