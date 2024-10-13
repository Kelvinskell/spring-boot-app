output "alb_dns" {
  description = "The public dns of the load balancer"
  value = module.alb.alb_dns
}

output "mysql_endpoint" {
  description = "The endpoint of the MYSQL Instance"
  value = module.rds.rds_endpoint
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS Service attached to the cluster"
  value = module.ecs.ecs_service_name
}

output "sns_topic_arn" {
  description = "The sns topic for jenkins deployments"
  value = module.monitoring.jenkins_topic_arn
}

output "aws_region" {
  description = "The AWS region to deploy infa"
  value = var.region
}