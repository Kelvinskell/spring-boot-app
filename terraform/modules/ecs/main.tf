# Create ECS Cluster
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${local.env}-${local.app}-cluster"
    Environment = local.env
    app = local.app
  }
}

# Create ECS Service
resource "aws_ecs_service" "ecs-svc" {
  name            = "ecs-app-svc"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.id
  desired_count = 2
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = var.tg_arn
    container_name   = "${local.app}-spring-boot-app-${local.env}"
    container_port   = 8080
  }

  network_configuration {
    subnets = var.private_subnets
    security_groups = [var.ecs_sg]
  }

  tags = {
    Name = "${local.env}-${local.app}-cluster"
    Environment = local.env
    app = local.app
  }
}