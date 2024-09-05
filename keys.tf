# # Upload certificates to S3
# resource "aws_s3_object" "private_key" {
#   bucket = aws_s3_bucket.certificates.bucket
#   key    = "certificates/private.key"
#   source = "path/to/your/local/private.key"
#   acl    = "private"
# }
#
# resource "aws_s3_object" "certificate_body" {
#   bucket = aws_s3_bucket.certificates.bucket
#   key    = "certificates/certificate.crt"
#   source = "path/to/your/local/certificate.crt"
#   acl    = "private"
# }
#
# resource "aws_s3_object" "certificate_chain" {
#   bucket = aws_s3_bucket.certificates.bucket
#   key    = "certificates/ca_bundle.crt"
#   source = "path/to/your/local/ca_bundle.crt"
#   acl    = "private"
# }
#
# # Retrieve certificates from S3
# data "aws_s3_object" "private_key" {
#   bucket = aws_s3_bucket.certificates.bucket
#   key    = "certificates/private.key"
# }
#
# data "aws_s3_object" "certificate_body" {
#   bucket = aws_s3_bucket.certificates.bucket
#   key    = "certificates/certificate.crt"
# }
#
# data "aws_s3_object" "certificate_chain" {
#   bucket = aws_s3_bucket.certificates.bucket
#   key    = "certificates/ca_bundle.crt"
# }
#
# # Import the certificates into AWS ACM
# resource "aws_acm_certificate" "imported_cert" {
#   private_key       = data.aws_s3_object.private_key.body
#   certificate_body  = data.aws_s3_object.certificate_body.body
#   certificate_chain = data.aws_s3_object.certificate_chain.body
#
#   tags = {
#     Name = "Imported Certificate"
#   }
# }

# Upload the self-signed certificate to AWS ACM
# resource "aws_acm_certificate" "self_signed_cert" {
#   private_key       = file("certs/private.key")        # Path to your private key
#   certificate_body  = file("certs/certificate.crt")    # Path to your certificate
#   certificate_chain = file("certs/certificate.crt")    # Path to the certificate chain (can be same as cert for self-signed)
#
#   tags = {
#     Name = "Self-Signed Certificate"
#   }
# }