resource "aws_lambda_function" "rds_setup_lambda" {
  function_name = "${local.app}-rds-setup-lambda-${local.env}"
  role          = aws_iam_role.lambda_rds_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  vpc_config {
    security_group_ids = [var.lambda_sg]  # Security group for Lambda to access RDS
    subnet_ids         = var.private_subnet_ids
  }
  environment {
    variables = {
      RDS_HOSTNAME = local.rds_hostname
      RDS_USERNAME = local.rds_credentials["username"]
      RDS_PASSWORD = local.rds_credentials["password"]
      RDS_DB_NAME  = "mydb"
    }
  }
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  # Ensure Lambda is deployed after the RDS instance
  depends_on = [aws_db_instance.mysql_rds, aws_iam_role.lambda_rds_role]

  tags = {
    Name = "${local.app}-mysql-function-${local.env}"
    Environment = local.env
    app = local.app
  }
}