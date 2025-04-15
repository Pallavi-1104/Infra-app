# modules/network/output.tf
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_public_1" {
  value = aws_subnet.subnet_public_1
}

output "subnet_public_2" {
  value = aws_subnet.subnet_public_2
}