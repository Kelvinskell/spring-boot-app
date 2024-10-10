# Define policy document
data "aws_iam_policy_document" "assume_role_task" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Create Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsapp_ECS_Task_Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_task.json

  inline_policy {
    name = "ecs_task_execution_policy_for_ecs_app"

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
                "logs:PutLogEvents",
            ],
            "Resource": "*"
        }
    ]
}
    )
  }
  tags = {
    Environment = local.env
    app = local.app
    Name = "${local.env}-${local.app}-ecs-role"
  }
}