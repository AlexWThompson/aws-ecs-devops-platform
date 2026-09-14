module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "aws-devops-ecs-service"
  vpc_id      = var.vpc_id

  ingress_rules = {
    https = {
      from_port   = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/16"
      description = "HTTPS from internal"
    }
    self-all = {
      ip_protocol                  = "-1"
      referenced_security_group_id = "self"
      description                  = "All traffic from members of this SG"
    }
  }

  egress_rules = {
    all = {
      ip_protocol = "TCP"
      to_port     = 443
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "prod"
  }
}