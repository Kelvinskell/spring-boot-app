# Data source to get the existing log group
data "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${local.app}/${local.env}"
}

resource "aws_cloudwatch_dashboard" "app_dashboard" {
  dashboard_name = "${local.app}-Dashboard-${local.env}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 24,
        height = 6,
        properties = {
          title      = "Recent Log Insights",
          metrics    = [
            ["AWS/Logs", "IncomingLogEvents", "LogGroupName", data.aws_cloudwatch_log_group.ecs_log_group.name],
          ],
          view       = "timeSeries",
          stacked    = false,
          region     = var.region
          period     = 300,
          stat       = "Sum",
        }
      }
    ]
  })
  depends_on = [ aws_cloudwatch_event_rule.ecs_task_success_rule ]
}