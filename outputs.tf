output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "service_arn" {
  value = "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_service.ui.id}"
}

output "service_id" {
  value = aws_ecs_service.ui.id
}

output "alb_dns_name" {
  value = aws_lb.app-alb.dns_name
}
