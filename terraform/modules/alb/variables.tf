variable "subnet_ids" {
  description = "Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "vpc_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}