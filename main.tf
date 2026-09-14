terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "terraform-state-bucket-527557824388-us-east-2-an"
    key          = "environments/prod/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }

}

module "vpc" {
  source = "./terraform/modules/vpc"
}

module "iam" {
  source = "./terraform/modules/iam"
}

module "ecr" {
  source = "./terraform/modules/ecr"
}

module "ecs" {
  source = "./terraform/modules/ecs"

  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  ecr_repository_url          = module.ecr.ecr_repository_url

  security_group_ids = module.sg.ecs_security_group_id
  subnet_ids         = module.vpc.private_subnets
}

module "sg" {
  source = "./terraform/modules/sg"

  vpc_id = module.vpc.vpc_id
}
