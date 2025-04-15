    # modules/ec2/variables.tf
    variable "vpc_id" {
      description = "The ID of the VPC"
      type        = string
    }

    variable "subnet_id" {
      description = "The ID of the Subnet"
      type        = string
    }
    variable "subnet_public_1_id" {
      description = "The ID of the Subnet"
      type        = string
    }
    variable "subnet_public_2_id" {
      description = "The ID of the Subnet"
      type        = string
    }