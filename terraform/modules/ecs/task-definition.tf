resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-app"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "5120"
  requires_compatibilities = ["FARGATE"]

   runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "Spring-Boot-App",
      "image" : var.image_name,
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "spring-boot-port",
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      environment          = [
      { "name" : "DB_USERNAME", "value" : var.mysql_username },
      { "name" : "DB_PASSWORD", "value" : var.mysql_password },
      { "name" : "DB_URL", "value" : var.mysql_endpoint }
    ],
      "essential" : true,
      "environmentFiles" : [],
      "mountPoints" : [],
      "volumesFrom" : [],
      "ulimits" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/ecs/${local.app}/${local.env}",
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        },
        "secretOptions" : []
      },
      "systemControls" : []
    }
  ])

  tags = {
    Name = "${local.env}-${local.app}-cluster"
    Environment = local.env
    app = local.app
  }
}