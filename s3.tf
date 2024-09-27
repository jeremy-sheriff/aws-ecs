resource "aws_s3_bucket" "db_bucket" {
  bucket = "db-sql-script"

  tags = {
    Name = "Sql Init Script"
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.db_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.db_bucket.id
  key    = "init.sql"
  source = "init.sql"
  etag   = filemd5("init.sql")
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.db_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.db_bucket.arn}/*"
      }
    ]
  })
}

output "my_bucket_file_version" {
  value = aws_s3_object.object.id
}
