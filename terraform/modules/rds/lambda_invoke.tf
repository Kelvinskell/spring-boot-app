resource "null_resource" "invoke_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      aws lambda invoke --function-name ${aws_lambda_function.rds_setup_lambda.function_name} --payload '{}' /dev/null
    EOT
  }

  # Ensure this executes only after the Lambda is created
  depends_on = [aws_lambda_function.rds_setup_lambda]
}