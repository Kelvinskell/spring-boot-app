output "alb_dns" {
  description = "The public dns of the load balancer"
  value = module.alb.alb_dns
}