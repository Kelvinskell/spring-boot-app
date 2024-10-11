output "ecs_cluster_name" {
    description = "name of ECS Cluster"
    value = aws_ecs_cluster.ecs-cluster.name
}

output "ecs_service_name" {
  description = "Name of ECS service"
  value = aws_ecs_service.ecs-svc.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the Cluster"
  value = aws_ecs_cluster.ecs-cluster.arn
}