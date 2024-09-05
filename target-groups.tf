resource "aws_lb_target_group" "ui" {
  name        = "ui-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}


resource "aws_lb_target_group" "keycloak" {
  name        = "keycloak-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/keycloak/auth/health"
    port                = "9000"  # Health check on port 9000
    interval            = 60
    timeout             = 10
    healthy_threshold   = 10
    unhealthy_threshold = 10
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "students" {
  name        = "students-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/students/health"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 10
    unhealthy_threshold = 10
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "library" {
  name        = "library-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/library/health"
    interval            = 60
    timeout             = 10
    healthy_threshold   = 10
    unhealthy_threshold = 10
    matcher             = "200-299"
  }
}