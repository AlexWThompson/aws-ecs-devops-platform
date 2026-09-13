output "ecs_task_execution_role_arn" {
  value = module.iam_task_execution_role.iam_role_arn
}

output "ecs_task_role_arn" {
  value = module.ecs_task_role.iam_role_arn
}