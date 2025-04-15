# modules/network/output.tf
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_public_1_id" {
  value = aws_subnet.subnet_public_1.id
}
output "subnet_public_2_id" {
  value = aws_subnet.subnet_public_2.id
}
