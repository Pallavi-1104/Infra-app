    # modules/network/main.tf
    resource "aws_vpc" "vpc" {
      cidr_block = "10.0.0.0/16"
    }

    resource "aws_subnet" "subnet_public_1" {
      vpc_id            = aws_vpc.vpc.id
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      map_public_ip_on_launch = true
    }

    resource "aws_subnet" "subnet_public_2" {
      vpc_id            = aws_vpc.vpc.id
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
      map_public_ip_on_launch = true
    }

    resource "aws_internet_gateway" "igw" {
      vpc_id = aws_vpc.vpc.id
    }

    resource "aws_route_table" "public_rt" {
      vpc_id = aws_vpc.vpc.id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
      }
    }

    resource "aws_route_table_association" "rta_public_1" {
      subnet_id      = aws_subnet.subnet_public_1.id
      route_table_id = aws_route_table.public_rt.id
    }

    resource "aws_route_table_association" "rta_public_2" {
      subnet_id      = aws_subnet.subnet_public_2.id
      route_table_id = aws_route_table.public_rt.id
    }

    resource "aws_security_group" "ecs_instance_sg" {
      name        = "ecs-instance-sg"
      description = "Security group for ECS instances"
      vpc_id      = aws_vpc.vpc.id

      ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"] # Adjust as needed
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    resource "aws_security_group" "lb_sg" {
      name        = "lb-sg"
      description = "Security group for the load balancer"
      vpc_id      = aws_vpc.vpc.id

      ingress {
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
    }

    output "vpc_id" {
      value = aws_vpc.vpc.id
    }

    output "subnet_public_1_id" {
      value = aws_subnet.subnet_public_1.id
    }
    output "subnet_public_2_id" {
      value = aws_subnet.subnet_public_2.id
    }
    