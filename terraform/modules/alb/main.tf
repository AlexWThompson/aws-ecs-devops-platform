module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "ecs-alb-http"
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnet_ids

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ecs"
      }
    }
  }

  target_groups = {
    ecs = {
      protocol         = "HTTP"
      port             = 8080
      target_type      = "ip"

      create_attachment = false

      health_check = {
        enabled  = true
        protocol = "HTTP"
        port     = "8080"
        path     = "/health"
      }
    }
  }

  security_groups = [var.security_groups]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}