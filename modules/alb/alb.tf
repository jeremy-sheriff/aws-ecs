# resource "aws_lb" "app-alb" {
#   name               = "app-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.ecs.id]
#   subnets            = [for subnet in aws_subnet.main : subnet.id]
#
#   enable_deletion_protection = false
# }
#
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.app-alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.CERT_ARN
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ui.arn
#   }
# }
#
#
#
#
# resource "aws_lb_listener_rule" "keycloak" {
#   listener_arn = aws_lb_listener.https_listener.arn
#   priority     = 200
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.keycloak.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/keycloak/*"]
#     }
#   }
#
#   tags = {
#     Name = "Keycloak Rule"
#   }
# }
#
# resource "aws_lb_listener_rule" "students" {
#   listener_arn = aws_lb_listener.https_listener.arn
#   priority     = 300
#
#   condition {
#     path_pattern {
#       values = ["/api/students/*"]
#     }
#   }
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.students.arn
#   }
#
#
#
#   tags = {
#     Name = "Students service Rule"
#   }
# }
#
# resource "aws_lb_listener_rule" "library" {
#   listener_arn = aws_lb_listener.https_listener.arn
#   priority     = 400
#
#   condition {
#     path_pattern {
#       values = ["/api/library/*"]
#     }
#   }
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.library.arn
#   }
#
#   tags = {
#     Name = "Library service Rule"
#   }
# }