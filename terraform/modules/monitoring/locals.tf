locals {
  env = var.env
  app = var.app
}


# Create a list of SNS topics ARNs
locals {
  sns_topics = {
    "failure" = aws_sns_topic.ecs_failure_topic.arn
    "success" = aws_sns_topic.ecs_success_topic.arn
    "cpu" = aws_sns_topic.ecs_cpu_topic.arn
    "jenkins" = aws_sns_topic.jenkins_deployment_topic.arn
  }
}