resource "aws_subnet" "private_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidr.private_zone1[var.env]
  availability_zone = local.zone1

  tags = {
    Name                                                 = "${local.env}-private-${local.zone1}-${local.app}-subnet"
    Environment = var.env
  }
}

resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidr.private_zone2[var.env]
  availability_zone = local.zone2

  tags = {
    Name                                                 = "${local.env}-private-${local.zone2}-${local.app}-subnet"
    Environment = var.env
  }
}

resource "aws_subnet" "public_zone1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidr.public_zone1[var.env]
  availability_zone       = local.zone1
  map_public_ip_on_launch = true

  tags = {
    Name                                                 = "${local.env}-public-${local.zone1}-${local.app}-subnet"
    Environment = var.env
  }
}

resource "aws_subnet" "public_zone2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidr.public_zone2[var.env]
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    Name                                                 = "${local.env}-public-${local.zone2}-${local.app}-subnet"
    Environment = var.env
  }
}