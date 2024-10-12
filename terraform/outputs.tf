output "alb_dns" {
  description = "The public dns of the load balancer"
  value = module.alb.alb_dns
}

output "mysql_endpoint" {
  description = "The endpoint of the MYSQL Instance"
  value = module.rds.rds_endpoint
}