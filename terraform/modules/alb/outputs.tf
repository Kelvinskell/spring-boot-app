output "tg_arn" {
  description = "The id of the load balancer target group"
  value       = aws_lb_target_group.tg.arn
}

output "alb_dns" {
  description = "The public DNS address of the load balancer"
  value = aws_lb.alb.dns_name
}