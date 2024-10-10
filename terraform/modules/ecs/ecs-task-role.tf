# Create Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.app}-ecs_task_execution_role-${local.env}"
  
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Environment = local.env
    app         = local.app
    Name = "${local.app}-ecs-task-role-${local.env}"
  }
}

# Create Policy
resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "${local.env}-ecs_task_execution_policy-${local.app}"
  role   = aws_iam_role.ecs_task_execution_role.id

    policy = jsonencode(
      {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:DescribeAlarms"
            ],
            "Resource": "*"
        }
    ]
}
    )
  }