module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "aws-devops-ecs-service"
  vpc_id      = var.vpc_id

  ingress_rules = {
    http = {
      from_port       = 8080
      ip_protocol     = "tcp"
      referenced_security_group_id = security_group_alb.id
      description     = "HTTPS from internal"
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

module "security_group_alb" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "aws-devops-alb-sg"
  vpc_id      = var.vpc_id

  ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
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
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "prod"
  }
}