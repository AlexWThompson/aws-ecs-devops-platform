variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups to attach to the ECS service"
  type        = string
}