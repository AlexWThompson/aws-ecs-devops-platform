module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "ecs-alb-http"
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnet_ids

  access_logs = {
    bucket = "my-alb-logs"
  }

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

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}