resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr[var.env]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = local.env
    Name = "${local.env}-${local.app}-vpc"
    app = local.app
  }
}