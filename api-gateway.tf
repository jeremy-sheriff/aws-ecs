# Define HTTP API Gateway
resource "aws_apigatewayv2_api" "school_http_api" {
  name          = "School HTTP API"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for the Schools microservice."

  cors_configuration {
    allow_origins = ["*"]  # Replace "*" with specific origins if needed
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]  # Allowed HTTP methods
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token", "X-Amz-User-Agent"]
    expose_headers = ["Content-Type", "X-Amz-Date", "X-Amz-Security-Token", "Authorization"]
    max_age = 3600  # Cache preflight response for 1 hour
  }
}

# Define the integration with ALB for /api/students/{proxy+}
resource "aws_apigatewayv2_integration" "students_proxy_integration" {
  api_id                    = aws_apigatewayv2_api.school_http_api.id
  integration_type          = "HTTP_PROXY"
  integration_method        = "ANY"
  integration_uri           = "https://${var.domain}/api/students/{proxy}"
  payload_format_version    = "1.0"
}

# Define the default route (/api/students/{proxy+})
resource "aws_apigatewayv2_route" "students_proxy_route" {
  api_id    = aws_apigatewayv2_api.school_http_api.id
  route_key = "ANY /students/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.students_proxy_integration.id}"
}

# Define the integration with ALB for /api/library/{proxy+}
resource "aws_apigatewayv2_integration" "library_proxy_integration" {
  api_id                    = aws_apigatewayv2_api.school_http_api.id
  integration_type          = "HTTP_PROXY"
  integration_method        = "ANY"
  integration_uri           = "https://${var.domain}/api/library/{proxy}"
  payload_format_version    = "1.0"
}

# Define the default route (/api/library/{proxy+})
resource "aws_apigatewayv2_route" "library_proxy_route" {
  api_id    = aws_apigatewayv2_api.school_http_api.id
  route_key = "ANY /library/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.library_proxy_integration.id}"
}

# Deploy the API Gateway
resource "aws_apigatewayv2_deployment" "students_api_deployment" {
  api_id = aws_apigatewayv2_api.school_http_api.id

  # Ensure the integration is ready before deploying
  depends_on = [
    aws_apigatewayv2_integration.students_proxy_integration,
    aws_apigatewayv2_route.students_proxy_route
  ]
}

# Create the prod stage
resource "aws_apigatewayv2_stage" "prod_stage" {
  api_id      = aws_apigatewayv2_api.school_http_api.id
  name        = "prod"  # Stage name
  deployment_id = aws_apigatewayv2_deployment.students_api_deployment.id

  auto_deploy = false  # Automatically deploy changes to the stage
}

# Get the API Gateway endpoint
# Get the API Gateway domain (without protocol)
locals {
  api_gateway_dns = replace(aws_apigatewayv2_api.school_http_api.api_endpoint, "https://", "")
}



# Create a custom domain for API Gateway
resource "aws_apigatewayv2_domain_name" "muhohodev_custom_domain" {
  domain_name = "api.muhohodev.com"  # Your custom domain
  domain_name_configuration {
    certificate_arn = var.SUB_DOMAINS_CERT_ARN  # ACM certificate for api.muhohodev.com
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "muhohodev_api_gateway" {
  zone_id = var.ZONE_ID  # Your Route 53 hosted zone ID for muhohodev.com
  name    = "api.muhohodev.com"  # The subdomain you want to point to the API Gateway
  type    = "CNAME"

  # Point to the API Gateway custom domain name (indexed properly)
  ttl     = 300
  records = [aws_apigatewayv2_domain_name.muhohodev_custom_domain.domain_name_configuration[0].target_domain_name]
}

# Create an API mapping for the custom domain
resource "aws_apigatewayv2_api_mapping" "muhohodev_api_mapping" {
  api_id       = aws_apigatewayv2_api.school_http_api.id
  domain_name  = aws_apigatewayv2_domain_name.muhohodev_custom_domain.domain_name
  stage        = aws_apigatewayv2_stage.prod_stage.name
  api_mapping_key = ""  # Leave empty to map the root of the domain
}





