# Create CloudWatch Alarm for ECS service CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-utilization-${local.env}-${local.app}"
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

# Create SNS Topic for alarm notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "ecs-${local.env}-${local.app}-alarms"
  tags = {
    Environment = local.env
    app         = local.app
    Name = "ecs-${local.env}-${local.app}-sns"
  }
}

# Create data source to refer to identity caller
data "aws_caller_identity" "current" {}