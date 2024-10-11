# Create SNS Topic for CPU Utilization alarm notifications
resource "aws_sns_topic" "ecs_cpu_topic" {
  name = "ecs-${local.env}-${local.app}-cpu-alarm"
  tags = {
    Environment = local.env
    app         = local.app
    Name = "ecs-${local.env}-${local.app}-cpu-sns"
  }
}

# Create SNS Topic for Task Failure notifications
resource "aws_sns_topic" "ecs_task_failure_topic" {
  name = "${local.env}-ecs-failure-notification-topic-${local.app}"
  tags = {
    Environment = local.env
    app         = local.app
    Name = "ecs-${local.env}-${local.app}-task-failure-sns"
  }
}

# SNS topic for task success notifications
resource "aws_sns_topic" "ecs_task_success_topic" {
  name = "${local.env}-ecs-success-notification-topic-${local.app}"
  tags = {
    Environment = local.env
    app         = local.app
    Name = "ecs-${local.env}-${local.app}-task-success-sns"
  }
}

# SNS topic for Successful Jenkins Deployment
resource "aws_sns_topic" "jenkins_deployment_topic" {
  name = "${local.env}-jenkins-deployment-topic-${local.app}"
  tags = {
    Environment = local.env
    app         = local.app
    Name = "${local.env}-${local.app}-jenkins-deployment-sns"
  }
}

# Create a single subscription for all topics
resource "aws_sns_topic_subscription" "ecs_email_subscription" {
  for_each = local.sns_topics

  topic_arn = each.value
  protocol  = "email"
  endpoint  = var.sns_email_address
}
