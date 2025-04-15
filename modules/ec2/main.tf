# modules/ec2/main.tf

resource "random_id" "sg_id" {
  byte_length = 8
}

resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs-instance-sg-${random_id.sg_id.hex}"  # Unique name
  description = "Security group for ECS EC2 instances"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "random_id" "role_id" {
  byte_length = 8
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role-${random_id.role_id.hex}"  # Unique role name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  image_id             = data.aws_ssm_parameter.ecs_ami.value  # Get the latest ECS AMI from SSM
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.ecs_instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  associate_public_ip_address = true
}


resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [var.subnet_id]
  launch_configuration = aws_launch_configuration.ecs_launch_configuration.name
  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ecs_instance_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  tags = {
    Name = "ECS EC2 Instance"
  }
}