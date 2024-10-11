# Create CloudWatch Alarm for ECS service CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${local.env}-high-cpu-utilization-${local.app}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.ecs_cpu_topic.arn]
  dimensions = {
    ClusterName  = var.ecs_cluster_name
    ServiceName  = var.ecs_service_name
  }
  tags = {
    Environment = local.env
    app         = local.app
  }
}

# CloudWatch Alarm for Successful Running Tasks
resource "aws_cloudwatch_metric_alarm" "ecs_task_success_alarm" {
  alarm_name          = "ecs-task-successful-running"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1 

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions      = [aws_sns_topic.ecs_task_success_topic.arn]
  ok_actions         = []
  insufficient_data_actions = []

  # Conditional treat_missing_data behavior for successful tasks
  treat_missing_data = var.single_notification ? "notBreaching" : "missing"
  tags = {
    Environment = local.env
    app         = local.app
  }
}

resource "aws_cloudwatch_event_rule" "ecs_task_failure_rule" {
  name        = "${local.env}-ecs-task-failure-rule-${local.app}"
  description = "Event rule to capture ECS task failures for ${local.app} in ${local.env} environment"
  event_pattern = jsonencode({
    "source" = ["aws.ecs"],
    "detail-type" = ["ECS Task State Change"],
    "detail" = {
      "clusterArn" = [var.ecs_cluster_arn],
      "lastStatus" = ["STOPPED"],
      "stoppedReason" = [
        "Essential container in task exited",
        "Task failed",
        "Task timed out",
        "User initiated stop"
        ]
    }
  })
  tags = {
    app = local.app
    Environment = local.env
    Name = "${local.env}-ecs-task-failure-events-${local.app}"
  }
}

resource "aws_cloudwatch_event_target" "ecs_failure_target" {
  rule      = aws_cloudwatch_event_rule.ecs_task_failure_rule.name
  arn       = aws_sns_topic.ecs_task_failure_topic.arn
}