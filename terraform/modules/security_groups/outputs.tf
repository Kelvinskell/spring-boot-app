output "Alb-sg_id" {
  description = "The id of the load balancer security group"
  value       = aws_security_group.alb_sg.id
}

output "ECS-sg_id" {
  description = "The id of the ECS service security group"
  value       = aws_security_group.ecs_sg.id
}