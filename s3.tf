resource "aws_s3_bucket" "certificates" {
  bucket = "ecs-certificate-bucket"

  tags = {
    Name = "Certificate Storage"
  }
}
