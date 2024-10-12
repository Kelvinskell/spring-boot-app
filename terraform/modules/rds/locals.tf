locals {
  env = var.env
  app = var.app
}

locals {
  rds_hostname = replace(aws_db_instance.mysql_rds.endpoint, ":3306", "")
}