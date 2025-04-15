# modules/ec2/variables.tf
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "name_prefix" {
  description = "Unique prefix to avoid IAM name conflicts"
  type        = string
}
