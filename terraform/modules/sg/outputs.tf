output "ecs_security_group_id" {
    value = module.security_group.id
}

output "alb_security_group_id" {
    value = module.security_group_alb.id
}