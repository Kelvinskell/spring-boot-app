# Create MySQL credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "${var.env}/mysql-rds-credentials"
  description = "MySQL RDS credentials for ${var.env} environment"
  
  tags = {
    Environment = var.env
    app         = var.app
    Name = "${local.env}-${local.app}-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })

  depends_on = [ aws_secretsmanager_secret.rds_secret ]
}

# Fetch the secret values from Secrets Manager
data "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.env}/mysql-rds-credentials"
  depends_on = [aws_secretsmanager_secret.rds_secret]
}

data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

# Parse the secret string to use in the database connection
locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)
}