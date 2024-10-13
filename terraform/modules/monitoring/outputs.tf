output "jenkins_topic_arn" {
  description = "The SNS topic to be used for jenkins deployments"
  value = aws_sns_topic.jenkins_deployment_topic.arn
}