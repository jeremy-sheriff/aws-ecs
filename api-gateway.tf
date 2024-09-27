# # Define an API Gateway REST API
# resource "aws_api_gateway_rest_api" "muhohodev_api" {
#   name        = "MuhohoDevAPI"
#   description = "API Gateway for muhohodev.com"
# }
#
# # Create Resource for 'api' path part
# resource "aws_api_gateway_resource" "api" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   parent_id   = aws_api_gateway_rest_api.muhohodev_api.root_resource_id
#   path_part   = "api"
# }
#
# # Create Resource for students service under 'api' path
# resource "aws_api_gateway_resource" "students" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   parent_id   = aws_api_gateway_resource.api.id
#   path_part   = "students"
# }
#
# # Create GET method for students service
# resource "aws_api_gateway_method" "students_get" {
#   rest_api_id   = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id   = aws_api_gateway_resource.students.id
#   http_method   = "GET"
#   authorization = "NONE"
# }
#
# # Integrate API Gateway with ALB endpoint for students
# resource "aws_api_gateway_integration" "students_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id             = aws_api_gateway_resource.students.id
#   http_method             = aws_api_gateway_method.students_get.http_method
#   type                    = "HTTP"
#   integration_http_method = "GET"
#   uri                     = "https://${aws_lb.app-alb.dns_name}/api/students"
# }
#
# # Create Resource for library service under 'api' path
# resource "aws_api_gateway_resource" "library" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   parent_id   = aws_api_gateway_resource.api.id
#   path_part   = "library"
# }
#
# # Create GET method for library service
# resource "aws_api_gateway_method" "library_get" {
#   rest_api_id   = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id   = aws_api_gateway_resource.library.id
#   http_method   = "GET"
#   authorization = "NONE"
# }
#
# # Integrate API Gateway with ALB endpoint for library
# resource "aws_api_gateway_integration" "library_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id             = aws_api_gateway_resource.library.id
#   http_method             = aws_api_gateway_method.library_get.http_method
#   type                    = "HTTP"
#   integration_http_method = "GET"
#   uri                     = "https://${aws_lb.app-alb.dns_name}/api/library"
# }
#
# # Deploy the API Gateway to a stage
# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   stage_name  = "dev"
#
#   depends_on = [
#     aws_api_gateway_method.students_get,
#     aws_api_gateway_integration.students_integration,
#     aws_api_gateway_method.library_get,
#     aws_api_gateway_integration.library_integration,
#     aws_api_gateway_method.keycloak_auth_get,
#     aws_api_gateway_integration.keycloak_auth_integration
#   ]
# }
#
#
#
# resource "aws_api_gateway_domain_name" "custom_domain" {
#   domain_name = "muhohodev.com"  # Use "api.muhohodev.com" if you prefer a subdomain
#   regional_certificate_arn = var.CERT_ARN
#   endpoint_configuration {
#     types = ["REGIONAL"]  # or "EDGE" based on your requirements
#   }
# }
#
# resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
#   domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
#   api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   stage_name  = aws_api_gateway_deployment.deployment.stage_name
# }
#
# resource "aws_route53_record" "api_gateway_record" {
#   zone_id = var.ZONE_ID
#   name    = "muhohodev.com"
#   type    = "A"
#
#   alias {
#     name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
#     evaluate_target_health = false
#   }
# }
#
# # Create Resource for keycloak service under root path
# resource "aws_api_gateway_resource" "keycloak" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   parent_id   = aws_api_gateway_rest_api.muhohodev_api.root_resource_id
#   path_part   = "keycloak"
# }
#
# # Create Resource for auth under keycloak path
# resource "aws_api_gateway_resource" "keycloak_auth" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   parent_id   = aws_api_gateway_resource.keycloak.id
#   path_part   = "auth"
# }
#
# # Create GET method for keycloak auth service
# resource "aws_api_gateway_method" "keycloak_auth_get" {
#   rest_api_id   = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id   = aws_api_gateway_resource.keycloak_auth.id
#   http_method   = "GET"
#   authorization = "NONE"
# }
#
# # Integrate API Gateway with ALB endpoint for keycloak auth
# resource "aws_api_gateway_integration" "keycloak_auth_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id             = aws_api_gateway_resource.keycloak_auth.id
#   http_method             = aws_api_gateway_method.keycloak_auth_get.http_method
#   type                    = "HTTP"
#   integration_http_method = "GET"
#   uri                     = "https://${aws_lb.app-alb.dns_name}/keycloak/auth"
# }
#
# # Create Resource for admin under keycloak_auth path
# resource "aws_api_gateway_resource" "keycloak_auth_admin" {
#   rest_api_id = aws_api_gateway_rest_api.muhohodev_api.id
#   parent_id   = aws_api_gateway_resource.keycloak_auth.id
#   path_part   = "admin"
# }
#
# # Create GET method for keycloak auth admin service
# resource "aws_api_gateway_method" "keycloak_auth_admin_get" {
#   rest_api_id   = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id   = aws_api_gateway_resource.keycloak_auth_admin.id
#   http_method   = "GET"
#   authorization = "NONE"
# }
#
# # Integrate API Gateway with ALB endpoint for keycloak auth admin
# resource "aws_api_gateway_integration" "keycloak_auth_admin_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.muhohodev_api.id
#   resource_id             = aws_api_gateway_resource.keycloak_auth_admin.id
#   http_method             = aws_api_gateway_method.keycloak_auth_admin_get.http_method
#   type                    = "HTTP"
#   integration_http_method = "GET"
#   uri                     = "https://${aws_lb.app-alb.dns_name}/keycloak/auth/admin"
# }
#
#
#
#
