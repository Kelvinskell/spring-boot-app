resource "aws_iam_role" "cloudwatch_alarm_role" {
  name = "cloudwatch_alarm_role"

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
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sns_topic.alarm_topic.name}"
        ]
      }
    ]
  })
}
