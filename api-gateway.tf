# School HTTP API Gateway
resource "aws_apigatewayv2_api" "school_http_api" {
  name          = "School HTTP API"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for the Schools microservice."

  cors_configuration {
    allow_origins   = ["https://muhohodev.com"]
    allow_methods   = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers   = ["Content-Type", "Authorization"]  # Allow necessary headers only
    expose_headers  = ["Content-Type", "X-Amz-Date", "X-Amz-Security-Token", "Authorization"]
    max_age         = 3600
  }
}

# JWT Authorizer for the API Gateway
resource "aws_apigatewayv2_authorizer" "school_jwt_authorizer" {
  api_id          = aws_apigatewayv2_api.school_http_api.id
  name            = "schoolAuthorizer"
  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = var.ISSUER
    audience = ["account"]  # The audience that you want to verify
  }
}

# Define Integrations for Library and Students Services
resource "aws_apigatewayv2_integration" "students_proxy_integration" {
  api_id                 = aws_apigatewayv2_api.school_http_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "https://${var.domain}/api/students/{proxy}"
  payload_format_version = "1.0"

  # Add credentials_arn field to specify the role API Gateway will assume
  credentials_arn        = aws_iam_role.api_gateway_lambda_invoke_role.arn
}

resource "aws_apigatewayv2_integration" "library_proxy_integration" {
  api_id                 = aws_apigatewayv2_api.school_http_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "https://${var.domain}/api/library/{proxy}"
  payload_format_version = "1.0"
}

# Define Routes for Library and Students
resource "aws_apigatewayv2_route" "library_proxy_route" {
  api_id    = aws_apigatewayv2_api.school_http_api.id
  route_key = "ANY /library/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.library_proxy_integration.id}"

  # Apply the JWT authorizer
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.school_jwt_authorizer.id
}

resource "aws_apigatewayv2_route" "students_proxy_route" {
  api_id    = aws_apigatewayv2_api.school_http_api.id
  route_key = "ANY /students/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.students_proxy_integration.id}"

  # Apply the JWT authorizer
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.school_jwt_authorizer.id
}

# Deployment and Stage Configuration
resource "aws_apigatewayv2_deployment" "students_api_deployment" {
  api_id = aws_apigatewayv2_api.school_http_api.id

  # Ensure the integrations and routes are ready before deploying
  depends_on = [
    aws_apigatewayv2_integration.students_proxy_integration,
    aws_apigatewayv2_route.students_proxy_route,
    aws_apigatewayv2_integration.students_proxy_integration,
    aws_apigatewayv2_integration.students_options_integration,
    aws_apigatewayv2_route.students_options_route
  ]
}


# API Gateway Stage with Access Logging
# API Gateway Stage with Access Logging and Throttling
resource "aws_apigatewayv2_stage" "production_stage" {
  api_id       = aws_apigatewayv2_api.school_http_api.id
  name         = "production"  # Stage name
  deployment_id = aws_apigatewayv2_deployment.students_api_deployment.id
  auto_deploy  = false  # Manually deploy changes to the stage

  # Enable logging in the stage
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format          = jsonencode({
      requestId        = "$context.requestId",
      ip               = "$context.identity.sourceIp",
      caller           = "$context.identity.caller",
      user             = "$context.identity.user",
      requestTime      = "$context.requestTime",
      httpMethod       = "$context.httpMethod",
      resourcePath     = "$context.resourcePath",
      status           = "$context.status",
      protocol         = "$context.protocol",
      responseLength   = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  # Enable execution logging and detailed metrics
  default_route_settings {
    detailed_metrics_enabled = true
    logging_level            = "INFO"  # You can set this to ERROR or INFO
    data_trace_enabled       = true    # Logs the request and response data

    # Throttling settings
    throttling_burst_limit = 200  # Burst capacity (requests per second)
    throttling_rate_limit  = 100  # Steady-state rate limit (requests per second)
  }
}


# Define Custom Domain Name for API Gateway
resource "aws_apigatewayv2_domain_name" "muhohodev_custom_domain" {
  domain_name = "api.muhohodev.com"  # Your custom domain

  domain_name_configuration {
    certificate_arn = var.SUB_DOMAINS_CERT_ARN  # ACM certificate for api.muhohodev.com
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Route 53 Record for Custom Domain
resource "aws_route53_record" "muhohodev_api_gateway" {
  zone_id = var.ZONE_ID  # Your Route 53 hosted zone ID for muhohodev.com
  name    = "api.muhohodev.com"  # The subdomain to point to the API Gateway
  type    = "CNAME"
  ttl     = 300
  records = [aws_apigatewayv2_domain_name.muhohodev_custom_domain.domain_name_configuration[0].target_domain_name]
}

# API Mapping for Custom Domain to API Gateway
resource "aws_apigatewayv2_api_mapping" "muhohodev_api_mapping" {
  api_id        = aws_apigatewayv2_api.school_http_api.id
  domain_name   = aws_apigatewayv2_domain_name.muhohodev_custom_domain.domain_name
  stage         = aws_apigatewayv2_stage.production_stage.name
  api_mapping_key = ""  # Leave empty to map the root of the domain
}


# OPTIONS Route for Students CORS
resource "aws_apigatewayv2_route" "students_options_route" {
  api_id    = aws_apigatewayv2_api.school_http_api.id
  route_key = "OPTIONS /students/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.students_options_integration.id}"
}

# OPTIONS Route for Library CORS
resource "aws_apigatewayv2_route" "library_options_route" {
  api_id    = aws_apigatewayv2_api.school_http_api.id
  route_key = "OPTIONS /library/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.students_options_integration.id}"
}


# Lambda Integration for CORS
resource "aws_apigatewayv2_integration" "students_options_integration" {
  api_id                 = aws_apigatewayv2_api.school_http_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.school_lambda.arn
  payload_format_version = "2.0"

  # Add credentials_arn field to specify the role API Gateway will assume
  credentials_arn        = aws_iam_role.api_gateway_lambda_invoke_role.arn
}



# Create a CloudWatch Log Group for API Gateway logs
resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/school-http-api-logs"
  retention_in_days = 14  # Set log retention period (optional)
}

# Create an IAM role for API Gateway to write logs to CloudWatch
resource "aws_iam_role" "api_gw_logging_role" {
  name = "api-gateway-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to allow logging
resource "aws_iam_role_policy" "api_gw_logging_policy" {
  role = aws_iam_role.api_gw_logging_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}



# Existing API Gateway configuration continues below...
# (No changes required for your other resources, only stage needs logging settings)


