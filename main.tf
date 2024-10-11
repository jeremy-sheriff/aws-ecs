provider "aws" {
  region = var.region
}



locals {
  rds_endpoint_without_port = regex("^([^:]+)", aws_db_instance.postgres.endpoint)[0]
}

locals {
  subnet_ids = aws_subnet.main[*].id
}

locals {
  security_group_ids = [
    aws_security_group.ecs.id,
    aws_security_group.library_sg.id,
    aws_security_group.students_security_group.id
  ]
}


resource "aws_cloudwatch_log_group" "ui" {
  name              = "/ecs/ui"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "keycloak" {
  name              = "/ecs/keycloak"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "students" {
  name              = "/ecs/students"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "library" {
  name              = "/ecs/library"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "db" {
  name              = "/ecs/db-initializer"
  retention_in_days = 7
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" //256
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

resource "aws_route53_record" "muhohodev_alias" {
  zone_id = var.ZONE_ID
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.app-alb.dns_name
    zone_id                = aws_lb.app-alb.zone_id
    evaluate_target_health = true
  }
}






