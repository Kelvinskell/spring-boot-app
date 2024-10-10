# create Application Load Balancer
resource "aws_lb" "alb" {
  name                       = "${local.env}-ecs-${local.app}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg]
  subnets                    = var.public_subnets
  enable_deletion_protection = false

  tags = {
    Environment = local.env
    app = local.app
    Name = "${local.app}-ecs-alb"
  }
}

# Create target group
resource "aws_lb_target_group" "tg" {
  name     = "ecs-${local.app}-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 60
    matcher             = "200-299"
    path                = "/"
    port                = 5000
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 4
  }
  tags = {
    Environment = local.env
    app = local.app
  }
}

# Create listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg.arn
      }
      stickiness {
        enabled  = true
        duration = 120
      }
    }
  }
  tags = {
    Name        = "${local.env}ecs-${local.app}-alb-listener"
    Environment = local.env
    app = local.app
  }
}