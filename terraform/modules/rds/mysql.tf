# Create DB Subnet group
resource "aws_db_subnet_group" "default" {
  name        = "default-db-subnet-group"
  description = "Default DB subnet group"
  subnet_ids = var.private_subnet_ids
}

# Create RDS Instance for MYSQL
resource "aws_db_instance" "mysql_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  db_subnet_group_name = aws_db_subnet_group.default.name
  username             = local.rds_credentials["username"]
  password             = local.rds_credentials["password"]
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [var.rds_sg]  # Security group for RDS

  tags = {
    Name        = "${local.env}-mysql-rds${local.app}"
    Environment = local.env
    app = local.app
  }
}