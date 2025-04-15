# modules/ec2/main.tf
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = "",
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachment" {
  role_name = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  name_prefix          = "ecs-lc-"
  image_id            = "ami-0c55b9dcb338f9877" # Replace with a suitable Amazon Linux 2 AMI
  instance_type       = "t3.medium"
  security_groups     = [aws_security_group.ecs_instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  user_data           = data.template_file.ecs_agent_config.rendered
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "ecs_agent_config" {
  template = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
EOF
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "ecs-asg"
  launch_configuration      = aws_launch_configuration.ecs_launch_configuration.name
  vpc_zone_identifier       = [var.subnet_public_1_id, var.subnet_public_2_id]
  desired_capacity          = 2
  min_size                = 2
  max_size                = 4
  health_check_type         = "ECS"
  target_group_arns        = [aws_lb_target_group.target_group.arn]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ebs_volume" "mongodb_data_volume" {
  availability_zone = "us-east-1a"
  size              = 10
  type              = "gp2"
  tags = {
    Name = "mongodb-data-volume"
  }
}

resource "aws_volume_attachment" "mongodb_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.mongodb_data_volume.id
  instance_id = aws_instance.ec2_instance.id
  #  force_detach = true #<--- Not needed for initial attachment.
}

#  Create an EC2 instance.  This is a bit of a simplification, normally you'd have this
#  as part of the autoscaling group, or use a DaemonSet in Kubernetes.  For this example,
#  we'll create a single instance to attach the volume to.  YOU WILL NEED TO MANAGE HA YOURSELF.
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0c55b9dcb338f9877" #  Use the same AMI as your launch configuration
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ecs_instance_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.name
  user_data              = data.template_file.ecs_agent_config.rendered
  associate_public_ip    = true
}

output "asg_name" {
  value = aws_autoscaling_group.ecs_asg.name
}

    