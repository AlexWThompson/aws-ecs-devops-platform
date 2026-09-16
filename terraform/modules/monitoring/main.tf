module "ecs_cpu_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  alarm_name          = "ecs_task_CPU_alarm"
  alarm_description   = "ecs task has > 80% CPU load"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  period              = 300
  unit                = "Percent"
  statistic           = "Average"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  

  alarm_actions = []
}

module "ecs_mem_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  alarm_name          = "ecs_task_Mem_alarm"
  alarm_description   = "ecs task has > 80% Mem load"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  period              = 300
  unit                = "Percent"
  statistic           = "Average"

  namespace   = "AWS/ECS"
  metric_name = "MemUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  

  alarm_actions = [module.sns_email_topic.topic_id]
}

module "sns_email_topic" {
  source  = "terraform-aws-modules/sns/aws"

  name  = "CloudWatch_alarm_email"

  subscriptions = {
    email = {
      protocol = "email"
      endpoint = "awtsmt@gmail.com"
    }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}