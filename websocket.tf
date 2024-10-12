# Websockets
resource "aws_apigatewayv2_api" "school_websocket_api" {
  name          = "School WebSocket API"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  description = "Websocket API Gateway for the chat."
}

resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.school_websocket_api.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}

# Route to handle WebSocket messages with action 'sendMessage'
resource "aws_apigatewayv2_route" "message_route" {
  api_id    = aws_apigatewayv2_api.school_websocket_api.id
  route_key = "sendMessage"
  target    = "integrations/${aws_apigatewayv2_integration.message_integration.id}"
}

# WebSocket API Integration with the Lambda function
resource "aws_apigatewayv2_integration" "message_integration" {
  api_id                 = aws_apigatewayv2_api.school_websocket_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.websocket_message_lambda.invoke_arn
  payload_format_version = "1.0"  # Change to 1.0 for WebSocket APIs
}


# WebSocket API Integration for the $connect route
resource "aws_apigatewayv2_integration" "connect_integration" {
  api_id                 = aws_apigatewayv2_api.school_websocket_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.websocket_connect_lambda.invoke_arn  # Connect Lambda function ARN
  payload_format_version = "1.0"  # For WebSocket APIs, you need to use 1.0
  credentials_arn        = aws_iam_role.api_gateway_lambda_invoke_role.arn
  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "Lambda example"
  integration_method        = "POST"
}



resource "aws_apigatewayv2_deployment" "websocket_api_deployment" {
  api_id = aws_apigatewayv2_api.school_websocket_api.id

  depends_on = [
    aws_apigatewayv2_route.connect_route,
    aws_apigatewayv2_integration.connect_integration
  ]
}

resource "aws_apigatewayv2_stage" "websocket_stage" {
  api_id       = aws_apigatewayv2_api.school_websocket_api.id
  name         = "dev"
  deployment_id = aws_apigatewayv2_deployment.websocket_api_deployment.id
}

output "websocket_url" {
  value = "wss://${aws_apigatewayv2_api.school_websocket_api.api_endpoint}/${aws_apigatewayv2_stage.websocket_stage.name}"
  description = "The WebSocket URL for the School WebSocket API"
}




