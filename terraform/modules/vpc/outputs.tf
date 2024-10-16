output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
  sensitive = false
}

output "public_subnets" {
  description = "The subnet ids of public subnets"
  value = [aws_subnet.public_zone1.id, aws_subnet.public_zone2.id]
}

output "private_subnets" {
  description = "The subnet ids of private subnets"
  value = [aws_subnet.private_zone1.id, aws_subnet.private_zone2.id]
}