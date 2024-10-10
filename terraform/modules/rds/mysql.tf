resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = local.rds_credentials["username"]
  password             = local.rds_credentials["password"]
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [var.rds_sg]  # Security group for RDS

  tags = {
    Name        = "${local.env}-mysql-rds${local.app}"
    Environment = local.env
    app = local.app
  }
}