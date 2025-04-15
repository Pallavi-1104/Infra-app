variable "ami_id" {
  description = "AMI ID to launch instances with"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
}

variable "instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the instance"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to avoid naming conflicts"
  type        = string
}

