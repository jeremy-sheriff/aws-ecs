# # dynamo.tf
# resource "aws_dynamodb_table" "users_table" {
#   name           = "users"
#   billing_mode   = "PAY_PER_REQUEST"  # This mode automatically scales based on usage
#   hash_key       = "connection_id"          # Primary Key
#
#   attribute {
#     name = "connection_id"
#     type = "S"  # S for String, N for Number, B for Binary
#   }
#
#   tags = {
#     Name        = "Users Table"
#     Environment = "Production"
#   }
# }
