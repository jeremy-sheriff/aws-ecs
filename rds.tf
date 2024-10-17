resource "aws_db_instance" "postgres" {
  allocated_storage    = 20  # Minimum storage
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = "db.t3.micro"
  db_name              = var.DB_NAME
  username             = var.DB_USER
  password             = var.DB_PASSWORD
  skip_final_snapshot  = true
  publicly_accessible  = true // Don't do this in prod

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.postgres.name

  tags = {
    Name = "Postgres RDS"
  }
}


resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [for subnet in aws_subnet.main : subnet.id]

  tags = {
    Name = "Main subnet group"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name        = "custom-postgres-parameter-group"
  family      = "postgres16"
  description = "Custom parameter group for PostgreSQL 16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}