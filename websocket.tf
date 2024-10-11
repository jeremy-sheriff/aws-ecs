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
  integration_uri        = aws_lambda_function.websocket_message_lambda.arn
  payload_format_version = "1.0"  # Change to 1.0 for WebSocket APIs
}




resource "aws_apigatewayv2_deployment" "websocket_api_deployment" {
  api_id = aws_apigatewayv2_api.school_websocket_api.id

  depends_on = [
    aws_apigatewayv2_route.connect_route,
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




