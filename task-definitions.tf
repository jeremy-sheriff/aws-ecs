resource "aws_ecs_task_definition" "ui" {
  family                   = "ui-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "ui-container",
      image     = "muhohoweb/speech-ui:1.0.1",
      essential = true,
      environment = [
        {
          name  = "API_ENDPOINT"
          value = "https://${aws_lb.app-alb.dns_name}/api"
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

resource "aws_ecs_task_definition" "api" {
  family                   = "api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "api-container",
      image     = "muhohoweb/speech-api:1.0.4",
      essential = true,
      environment = [
        {
          name  = "PGHOST"
          value = local.rds_endpoint_without_port
        },
        {
          name  = "PGUSER"
          value = var.DB_USER
        },
        {
          name  = "PGDATABASE"
          value = "postgres"
        },
        {
          name  = "PGPASSWORD"
          value = var.DB_PASSWORD
        },
        {
          name  = "PGPORT"
          value = var.DB_PORT
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/api"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "api"
        }
      },
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
          protocol      = "tcp"
        }
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
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
  family                   = "keycloak"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "keycloak-container"
      image     = "quay.io/keycloak/keycloak:23.0.4"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        {
          name  = "KC_HEALTH_ENABLED"
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
          value = "https://${aws_lb.app-alb.dns_name}/keycloak/auth"
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
          value = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}/postgres"
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
          value = "false"
        },
        {
          name  = "KC_HOSTNAME_STRICT_HTTPS"
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
      command = ["start-dev", "--http-relative-path=keycloak/auth"],
#       healthCheck = {
#         command     = ["CMD-SHELL", "curl -f http://localhost:8080/keycloak/auth || exit 1"]
#         interval    = 30
#         timeout     = 5
#         retries     = 3
#         startPeriod = 0
#       }
    }
  ])
  execution_role_arn = var.taskExecutionRole
}