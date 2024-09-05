resource "aws_ecs_service" "ui" {
  name            = "ui-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for subnet in aws_subnet.main : subnet.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ui.arn
    container_name   = "ui-container"
    container_port   = 80
  }
}


resource "aws_ecs_service" "students_service" {
  name            = "students-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.students.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for subnet in aws_subnet.main : subnet.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.students.arn
    container_name   = "students-container"
    container_port   = 8081
  }
}

resource "aws_ecs_service" "library_service" {
  name            = "library-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.library.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for subnet in aws_subnet.main : subnet.id]
    security_groups = [aws_security_group.library_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.library.arn
    container_name   = "library-container"
    container_port   = 8080
  }
}

resource "aws_ecs_service" "keycloak" {
  name            = "keycloak-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.keycloak.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [for subnet in aws_subnet.main : subnet.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.keycloak.arn
    container_name   = "keycloak-container"
    container_port   = 8080
  }
}