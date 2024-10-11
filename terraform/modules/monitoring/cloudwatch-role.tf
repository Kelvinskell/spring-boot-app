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
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.ecs_failure_topic.name}",
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.ecs_success_topic.name}"     
        ]
      }
    ]
  })
}
