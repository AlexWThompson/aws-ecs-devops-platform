module "ecs_alarm" {
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