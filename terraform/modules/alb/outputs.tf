output "target_group_arn" {
  value = module.alb.target_groups["ecs"].arn
}