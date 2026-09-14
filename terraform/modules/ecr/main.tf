module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "aws-devops-ecs-repo"
  repository_image_tag_mutability = "IMMUTABLE"

  repository_image_scan_on_push = true

  repository_read_write_access_arns = ["arn:aws:iam::527557824388:role/GitubActions-S3_role"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 2 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 2
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}