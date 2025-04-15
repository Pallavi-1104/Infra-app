# modules/observability/variables.tf
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
variable "subnet_public_1_id" {
  description = "The ID of the public subnet 1"
  type        = string
}
variable "subnet_public_2_id" {
  description = "The ID of the public subnet 2"
  type        = string
}

