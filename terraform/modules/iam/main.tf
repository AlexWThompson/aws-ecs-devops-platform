module "iam_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "aws-devops-ecs-task-execution-role"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole"
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "ecs-tasks.amazonaws.com"
        ]
      }]
    }
  }

  policies = {
    AmazonECSTaskExecutionPolicy = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

module "iam_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "aws-devops-ecs-task-role"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole"
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "ecs-tasks.amazonaws.com"
        ]
      }]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}