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
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]
  dimensions = {
    ClusterName  = var.ecs_cluster_name
    ServiceName  = var.ecs_service_name
  }
  tags = {
    Environment = local.env
    app         = local.app
  }
}

# Create CloudWatch alarm for failed tasks
resource "aws_cloudwatch_metric_alarm" "ecs_task_failed_alarm" {
  alarm_name          = "${local.app}-ecs-task-failed-${local.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TaskFailed"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    ClusterName   = var.ecs_cluster_name
    ServiceName   = var.ecs_service_name
  }

  alarm_actions      = [aws_sns_topic.alarm_topic.arn]
  ok_actions         = []
  insufficient_data_actions = []

  # Conditional treat_missing_data behavior
  treat_missing_data = var.single_notification ? "notBreaching" : "breaching"

  # Set the alarm state manually to 'ALARM' after the first failure
  lifecycle {
    create_before_destroy = false
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

  alarm_actions      = [aws_sns_topic.ecs_success_topic.arn]
  ok_actions         = []
  insufficient_data_actions = []

  # Conditional treat_missing_data behavior for successful tasks
  treat_missing_data = var.single_notification ? "notBreaching" : "breaching"
  tags = {
    Environment = local.env
    app         = local.app
  }
}