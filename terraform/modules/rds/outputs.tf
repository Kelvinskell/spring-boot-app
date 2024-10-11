output "rds_endpoint" {
    description = "Endpoint of the MYSQL instance"
  value = aws_db_instance.mysql_rds.endpoint
}

output "mysql_username" {
  value = local.rds_credentials["username"]
  sensitive = true
}

output "mysql_password" {
  value = local.rds_credentials["password"]
  sensitive = true
}

output "rds_instance" {
  value = aws_db_instance.mysql_rds
}
