# # Create IAM role for the Lambda function
# resource "aws_iam_role" "lambda_execution_role" {
#   name = "lambda-execution-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }
#
# # Attach policy to allow API Gateway to invoke Lambda function
# resource "aws_iam_role_policy" "api_gateway_lambda_invoke_policy" {
#   role = aws_iam_role.api_gateway_lambda_invoke_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "lambda:InvokeFunction"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
#
# # Create IAM role for API Gateway
# resource "aws_iam_role" "api_gateway_lambda_invoke_role" {
#   name = "api-gateway-lambda-invoke-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "apigateway.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }
#
# # Attach policy to allow Lambda to log to CloudWatch and manage network interfaces
# resource "aws_iam_role_policy" "lambda_logging_policy" {
#   role = aws_iam_role.lambda_execution_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "ec2:CreateNetworkInterface",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DeleteNetworkInterface",
#           "ec2:AssignPrivateIpAddresses",
#           "ec2:UnassignPrivateIpAddresses"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
#
#
#
# # Create a custom CloudWatch log group for Lambda
# resource "aws_cloudwatch_log_group" "school_lambda_log_group" {
#   name              = "/aws/lambda/schoolLambda"
#   retention_in_days = 7  # Optional: sets log retention period to 7 days
# }
#
#
# # Create Lambda function
# resource "aws_lambda_function" "school_lambda" {
#   filename      = "lambda_function.zip"  # Ensure your Lambda code is zipped and available at this location
#   function_name = "schoolLambda"
#   role          = aws_iam_role.lambda_execution_role.arn
#   handler       = "index.handler"  # Assuming your Lambda handler is in index.mjs as 'handler'
#   runtime       = "nodejs20.x"
#
#   # Specify environment variables if needed (optional)
#   environment {
#     variables = {
#       STAGE = "prod"
#     }
#   }
#
#   # VPC Configuration
#   vpc_config {
#     subnet_ids         = local.subnet_ids
#     security_group_ids = local.security_group_ids
#   }
#
#   # Tags (optional)
#   tags = {
#     Name = "schoolLambdaFunction"
#   }
# }
#
#
#
#
#
# #WEB SOCKETS
#
# # Create a CloudWatch Log Group for Lambda (optional)
# resource "aws_cloudwatch_log_group" "websocket_lambda_log_group" {
#   name              = "/aws/lambda/websocket-message-handler"
#   retention_in_days = 7  # Customize retention if needed
# }
#
# # Create a CloudWatch Log Group for Lambda (optional)
# resource "aws_cloudwatch_log_group" "websocket_lambda_disconnect_log_group" {
#   name              = "/aws/lambda/lambda_disconnect_function"
#   retention_in_days = 7  # Customize retention if needed
# }
#
# # Create a CloudWatch Log Group for Lambda (optional)
# resource "aws_cloudwatch_log_group" "websocket_websocket_lambda_log_group" {
#   name              = "/aws/lambda/websocket-connect-handler"
#   retention_in_days = 7  # Customize retention if needed
# }
#
#
#
# # Zip the new Lambda function for $connect (optional, adjust as needed)
# resource "null_resource" "package_connect_lambda" {
#   provisioner "local-exec" {
#     command = "zip -j connect_lambda_function.zip ./websocket_lambda/index.js"
#     working_dir = path.module
#   }
#
#   triggers = {
#     always_run = timestamp()  # Always run this null resource when running `terraform apply`
#   }
# }
#
#
# # Zip the new Lambda function for $connect (optional, adjust as needed)
# resource "null_resource" "package_disconnect_lambda" {
#   provisioner "local-exec" {
#     command = "zip -j lambda_disconnect_function.zip ./lambda_disconnect_function/index.mjs"
#     working_dir = path.module
#   }
#
#   triggers = {
#     always_run = timestamp()  # Always run this null resource when running `terraform apply`
#   }
# }
#
# # Lambda function to handle WebSocket $connect route
# resource "aws_lambda_function" "websocket_disconnect_lambda" {
#   function_name    = "lambda_disconnect_function"
#   handler          = "index.handler"
#   runtime          = "nodejs20.x"
#   role             = aws_iam_role.web_socket_lambda_execution_role.arn
#   filename         = "${path.module}/lambda_disconnect_function.zip"  # Reference the ZIP file
#   source_code_hash = filebase64sha256("${path.module}/lambda_disconnect_function.zip")  # Compute hash of the zip file
#
#   depends_on = [
#     null_resource.package_disconnect_lambda,
#   ]  # Ensure the ZIP file is created first
# }
#
# # Lambda function to handle WebSocket $connect route
# resource "aws_lambda_function" "websocket_connect_lambda" {
#   function_name    = "websocket-connect-handler"
#   handler          = "index.handler"
#   runtime          = "nodejs20.x"
#   role             = aws_iam_role.web_socket_lambda_execution_role.arn
#   filename         = "${path.module}/connect_lambda_function.zip"  # Reference the ZIP file
#   source_code_hash = filebase64sha256("${path.module}/connect_lambda_function.zip")  # Compute hash of the zip file
#
#   depends_on = [
#     null_resource.package_connect_lambda,
#   ]  # Ensure the ZIP file is created first
# }
#
#
# # Zip the Lambda function (websocket handler)
# resource "null_resource" "package_lambda" {
#   provisioner "local-exec" {
#     command = "zip -j websocket-message-handler.zip ./websocket-message-handler/index.mjs"
#     working_dir = path.module
#   }
#
#   triggers = {
#     always_run = timestamp()  # Always run this null resource when running `terraform apply`
#   }
# }
#
# # Lambda function to handle WebSocket messages
# resource "aws_lambda_function" "websocket_message_lambda" {
#   function_name    = "websocket-message-handler"
#   handler          = "index.handler"
#   runtime       = "nodejs20.x"
#   role             = aws_iam_role.web_socket_lambda_execution_role.arn
#   filename         = "${path.module}/websocket-message-handler.zip"  # Reference the ZIP file
#   source_code_hash = filebase64sha256("${path.module}/websocket-message-handler.zip")  # Compute hash of the zip file
#
#   depends_on = [null_resource.package_lambda]  # Ensure the ZIP file is created first
# }
#
#
#
#
# # IAM role for Lambda to execute
# resource "aws_iam_role" "web_socket_lambda_execution_role" {
#   name = "web-sockets-lambda-execution-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }
#
# # Attach the policy for DynamoDB access to the Lambda role
# resource "aws_iam_policy" "lambda_dynamodb_policy" {
#   name = "lambda-dynamodb-access"
#
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "dynamodb:PutItem"
#         ],
#         Resource = "arn:aws:dynamodb:us-east-1:975049979529:table/users"
#         # Resource = aws_dynamodb_table.users_table
#       }
#     ]
#   })
# }
#
# # Attach the DynamoDB policy to the Lambda execution role
# resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy_to_lambda" {
#   role       = aws_iam_role.web_socket_lambda_execution_role.name
#   policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
# }
#
# resource "aws_iam_role_policy" "lambda_logs_policy" {
#   name   = "lambda-logs"
#   role   = aws_iam_role.web_socket_lambda_execution_role.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
#
#
#
#
