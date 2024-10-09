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

# Upload init.sql file to S3 bucket
resource "aws_s3_object" "init_sql" {
  bucket = aws_s3_bucket.db_bucket.id
  key    = "init.sql"
  source = "init.sql"
  etag   = filemd5("init.sql")
}

# Upload realm.json file to S3 bucket
resource "aws_s3_object" "realm_json" {
  bucket = aws_s3_bucket.db_bucket.id
  key    = "realm.json"
  source = "school-realm.json" # Replace with the local path to your realm.json file
  etag   = filemd5("school-realm.json")
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
  value = aws_s3_object.init_sql.id
}

output "realm_file_version" {
  value = aws_s3_object.realm_json.id
}
