resource "aws_ecs_task_definition" "ui" {
  depends_on = [null_resource.run_db_initializer]
  family                   = "ui-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      essential = true,
      name      = "ui-container",
      image     = var.UI_IMAGE,
      environment = [
        {
          name  = "API_ENDPOINT"
          value = "https://${var.domain}/api"
        }
      ],
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 0
      }
    }
  ])
  execution_role_arn = var.taskExecutionRole
}

resource "aws_ecs_task_definition" "keycloak" {
  depends_on = [null_resource.run_db_initializer]
  family                   = "keycloak"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "keycloak-container"
      image     = "quay.io/keycloak/keycloak:25.0"
      essential = true
      environment = [
        {
          name  = "KC_HEALTH_ENABLED"
          value = "true"
        },
        {
          name  = "KC_HOSTNAME_STRICT_HTTPS"
          value = "true"
        },
        {
          name  = "KC_METRICS_ENABLED"
          value = "true"
        },
        {
          name  = "KEYCLOAK_ADMIN"
          value = "admin"
        },
        {
          name  = "KEYCLOAK_ADMIN_PASSWORD"
          value = var.KEY_ADMIN_PASSWORD
        },
        {
          name  = "KC_HOSTNAME_ADMIN_URL"
          value = "https://${var.domain}/keycloak/auth"
        },
        {
          name  = "KC_HOSTNAME"
          value = var.domain
        },
        {
          name  = "KC_LOG_LEVEL"
          value = "DEBUG"
        },
        {
          name  = "KC_PROXY"
          value = "edge"
        },
        {
          name  = "KC_DB"
          value = var.DB_USER
        },
        {
          name  = "KC_DB_PASSWORD"
          value = var.DB_PASSWORD
        },
        {
          name  = "KC_DB_URL"
          value = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}/postgres?currentSchema=keycloak"
        },
        {
          name  = "KC_DB_USERNAME"
          value = "postgres"
        },
        {
          name  = "KC_HTTP_RELATIVE_PATH"
          value = "/auth"
        },
        {
          name  = "KC_HOSTNAME_STRICT"
          value = "true"
        },
        {
          name  = "KC_HTTP_ENABLED"
          value = "true"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/keycloak"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "keycloak"
        }
      },
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ],
      command = ["start", "--http-relative-path=keycloak/auth"],
      healthCheck = {
        command     = ["CMD-SHELL", "bash -c 'echo -e \"GET /keycloak/auth/health HTTP/1.1\\r\\nHost: localhost\\r\\n\\r\\n\" > /dev/tcp/localhost/9000 || exit 1'"]
        interval    = 30
        timeout     = 10
        retries     = 10
        startPeriod = 30
      }

    }
  ])
  execution_role_arn = var.taskExecutionRole
}

resource "aws_ecs_task_definition" "students" {
  depends_on = [null_resource.run_db_initializer]
  family                   = "students-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "students-container",
      image     = var.STUDENTS_IMAGE,
      essential = true,
      environment = [
        {
          "name": "DOCKER_IMAGE_NAME",
          "value": var.STUDENTS_IMAGE
        },
        {
          "name": "COURSE_URL",
          "value": "localhost:8083"
        },
        {
          "name": "KEY_CLOAK_USERNAME",
          "value": "app-user"
        },
        {
          "name": "KEY_CLOAK_PASSWORD",
          "value": var.KC_DB_PASSWORD
        },
        {
          "name": "KEY_CLOAK_ISSUER_URI",
          "value": "https://${var.domain}/keycloak/auth/realms/${var.KEY_CLOAK_REALM}"
        },
        {
          "name": "DB_PASSWORD",
          "value": var.DB_PASSWORD
        },
        {
          "name": "DB_USERNAME",
          "value": "postgres"
        },
        {
          "name": "DB_URL",
          "value": "jdbc:postgresql://${local.rds_endpoint_without_port}:5432/postgres"
        },
        {
          "name": "CORS_ALLOWED_ORIGINS",
          "value": var.domain
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/students"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "api"
        }
      },
      portMappings = [
        {
          containerPort = 8081,
          hostPort      = 8081,
          protocol      = "tcp"
        }
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8081/api/students/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 10
        startPeriod = 30
      }
    }
  ])

  execution_role_arn = var.taskExecutionRole
}

resource "aws_ecs_task_definition" "library" {
  depends_on = [null_resource.run_db_initializer]
  family                   = "library-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "library-container",
      image     = var.LIBRARY_IMAGE,
      essential = true,
      environment = [
        {
          "name": "STUDENTS_URL",
          "value": var.domain
        },
        {
          "name": "KEY_CLOAK_CLIENT_ID",
          "value": "students-service"
        },

        {
          "name": "KEY_CLOAK_USERNAME",
          "value": "app-user"
        },
        {
          "name": "KEY_CLOAK_PASSWORD",
          "value": var.KC_DB_PASSWORD
        },
        {
          "name": "KEY_CLOAK_ISSUER_URI",
          "value": "https://${var.domain}/keycloak/auth/realms/${var.KEY_CLOAK_REALM}"
        },
        {
          "name": "DB_PASSWORD",
          "value": var.DB_PASSWORD
        },
        {
          "name": "DB_USERNAME",
          "value": "postgres"
        },
        {
          "name": "DB_URL",
          "value": "jdbc:postgresql://${local.rds_endpoint_without_port}:5432/postgres"
        },
        {
          "name": "CORS_ALLOWED_ORIGINS",
          "value": var.domain
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/library"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "api-library"
        }
      },
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/api/library/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 10
        startPeriod = 30
      }
    }
  ])

  execution_role_arn = var.taskExecutionRole
}

resource "aws_ecs_task_definition" "db_initializer" {
  family                   = "db-initializer-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([
    {

      name      = "db-initializer-container",
      image     = "muhohoweb/db-initializer:1.0.0", # Use your custom image
      essential = true,
      entryPoint = ["sh", "-c"],
      command = [
        "psql -h ${local.rds_endpoint_without_port} -U ${var.DB_USER} -d ${var.DB_NAME} -p 5432 -c \"CREATE SCHEMA if not exists students; CREATE SCHEMA if not exists library; CREATE SCHEMA if not exists keycloak;\""
      ],
      environment = [
        {
          name  = "PGPASSWORD",
          value = var.DB_PASSWORD
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/db-initializer"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "db-init"
        }
      }
    }
  ])

  execution_role_arn = var.taskExecutionRole
}

resource "null_resource" "run_db_initializer" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecs run-task \
        --cluster ${aws_ecs_cluster.main.name} \
        --task-definition ${aws_ecs_task_definition.db_initializer.family} \
        --network-configuration "awsvpcConfiguration={subnets=[${join(",", local.subnet_ids)}],securityGroups=[${join(",", local.security_group_ids)}],assignPublicIp=ENABLED}" \
        --launch-type FARGATE
    EOT
  }

  depends_on = [
    aws_ecs_task_definition.db_initializer
  ]
}



