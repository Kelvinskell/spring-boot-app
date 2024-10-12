resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${local.app}-${local.env}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = local.env
    app = local.app
    Name = "${local.app}-alb-sg"
  }
}

# ECS Service Security group  
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-${local.app}-${local.env}"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_security_group.alb_sg]

  tags = {
    Environment = local.env
    app = local.app
    Name = "${local.app}-ecs-sg"
  }
}

# Create RDS Sec group
resource "aws_security_group" "rds_sg" {
  name        = "${var.env}-rds-sg"
  description = "Allow MySQL inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-rds-sg-${local.app}"
    Environment = var.env
    app = local.app
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "${local.env}-lambda-sg-${local.app}"
  description = "Security group for Lambda to access RDS"
  vpc_id      = var.vpc_id  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.env}-lambda-sg-${local.app}"
    Environment = local.env
    app         = local.app
  }

  depends_on = [ var.lambda_eni_policy ]
}