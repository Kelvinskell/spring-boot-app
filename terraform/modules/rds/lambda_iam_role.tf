resource "aws_iam_role" "lambda_rds_role" {
  name = "${var.env}-lambda_rds_role-${var.app}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
  tags = {
    Name = "${local.app}-lamda-exec-role-${local.env}"
    Environment = local.env
    app = local.app
  }
}

resource "aws_iam_policy" "lambda_vpc_access" {
  name        = "${local.env}-lambda-vpc-access"
  description = "Allow Lambda to create network interfaces in VPC"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeNetworkInterfaceAttribute",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "rds:DescribeDBInstances",
          "rds:Connect",

        ]
        Resource = "*"
      },
      {
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement",
        "rds-data:BeginTransaction",
        "rds-data:CommitTransaction",
        "rds-data:RollbackTransaction"
      ],
      "Resource": aws_db_instance.mysql_rds.arn
    }
    ]
  })
  tags = {
    Name = "${local.env}-lambda-rds-policy-${local.app}"
    Environment = local.env
    app = local.app
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
  role       = aws_iam_role.lambda_rds_role.name
}

resource "aws_iam_policy_attachment" "lambda_rds_policy" {
  name       = "lambda-rds-policy-attachment"
  roles      = [aws_iam_role.lambda_rds_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" 
}