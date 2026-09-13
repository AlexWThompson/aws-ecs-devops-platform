output "ecs_task_execution_role_arn" {
  value = module.iam_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = module.iam_task_role.arn
}