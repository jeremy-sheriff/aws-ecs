provider "aws" {
  region = var.region
}

locals {
  rds_endpoint_without_port = regex("^([^:]+)", aws_db_instance.postgres.endpoint)[0]
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/api"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "keycloak" {
  name              = "/ecs/keycloak"
  retention_in_days = 7
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Jeremy Vpc"
  }
}

resource "aws_subnet" "main" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "ecs" {
  name_prefix = "ecs-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ecs Security Group"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow ECS tasks to access RDS"
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}



resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = element(aws_subnet.main.*.id, 0)
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = element(aws_subnet.main.*.id, 1)
  route_table_id = aws_route_table.main.id
}

data "aws_caller_identity" "current" {}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20  # Minimum storage
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = "db.t3.micro"
  username             = var.DB_USER
  password             = var.DB_PASSWORD
  skip_final_snapshot  = true
  publicly_accessible  = false

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
