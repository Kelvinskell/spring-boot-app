# Create data source to refer to identity caller
data "aws_caller_identity" "current" {}
resource "aws_iam_role" "cloudwatch_alarm_role" {
  name = "${local.app}-cloudwatch_alarm_role-${local.env}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudwatch.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${local.app}-cloudwatch_alarm_role-${local.env}"
    Environment = local.env
    app = local.app
  }
}

resource "aws_iam_role_policy" "cloudwatch_alarm_policy" {
  name   = "cloudwatch_alarm_policy"
  role   = aws_iam_role.cloudwatch_alarm_role.id
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sns:Publish"
        ],
        "Resource": [
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.ecs_cpu_topic.name}",
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.ecs_task_failure_topic.name}",
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.ecs_task_success_topic.name}"     
        ]
      }
    ]
  })
}

resource "aws_iam_role" "eventbridge_to_sns_role" {
  name = "${local.env}-eventbridge-to-sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
  tags = {
    Name = "${local.env}-${local.app}-eventbridge_to_sns_policy"
    Environment = local.env
    app = local.app
  }
}

resource "aws_iam_policy" "eventbridge_to_sns_policy" {
  name        = "${local.env}-eventbridge-to-sns-policy"
  description = "Policy to allow EventBridge to send messages to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sns:Publish"
      Resource = aws_sns_topic.ecs_task_failure_topic.arn
    }]
  })
  tags = {
    Name = "${local.env}-${local.app}-eventbridge_to_sns_policy"
    Environment = local.env
    app = local.app
  }
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.eventbridge_to_sns_policy.arn
  role       = aws_iam_role.eventbridge_to_sns_role.name
}
