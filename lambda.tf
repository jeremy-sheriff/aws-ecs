# Create IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policy to allow API Gateway to invoke Lambda function
resource "aws_iam_role_policy" "api_gateway_lambda_invoke_policy" {
  role = aws_iam_role.api_gateway_lambda_invoke_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = "*"
      }
    ]
  })
}

# Create IAM role for API Gateway
resource "aws_iam_role" "api_gateway_lambda_invoke_role" {
  name = "api-gateway-lambda-invoke-role"

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

# Attach policy to allow Lambda to log to CloudWatch and manage network interfaces
resource "aws_iam_role_policy" "lambda_logging_policy" {
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Resource = "*"
      }
    ]
  })
}



# Create a custom CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "school_lambda_log_group" {
  name              = "/aws/lambda/schoolLambda"
  retention_in_days = 7  # Optional: sets log retention period to 7 days
}

# Create Lambda function
resource "aws_lambda_function" "school_lambda" {
  filename      = "lambda_function.zip"  # Ensure your Lambda code is zipped and available at this location
  function_name = "schoolLambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"  # Assuming your Lambda handler is in index.js as 'handler'
  runtime       = "nodejs20.x"

  # Specify environment variables if needed (optional)
  environment {
    variables = {
      STAGE = "prod"
    }
  }

  # VPC Configuration
  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.security_group_ids
  }

  # Tags (optional)
  tags = {
    Name = "schoolLambdaFunction"
  }
}


