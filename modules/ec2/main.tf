# modules/ec2/main.tf

resource "aws_security_group" "ecs_instance_sg" {
  name        = "${var.name_prefix}-ecs-instance-sg"
  description = "SG for ECS instance"
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
  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups              = [var.security_group_id]
  }

  user_data = base64encode(file("${path.module}/user_data.sh"))
}




resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [var.subnet_id]
  launch_template {
  id      = aws_launch_template.ecs_launch_template.id
  version = "$Latest"
}
  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}

/*resource "aws_ecs_service" "prometheus_grafana" {
  name            = "prometheus-grafana"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.prometheus_grafana.arn
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  desired_count = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.prometheus_listener]
}*/

/*resource "aws_lb_target_group" "prometheus_tg" {
  name     = "prometheus-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}*/

#resource "aws_lb_listener" "prometheus_listener" {
 # load_balancer_arn = var.alb_arn
  #port              = 9090
  #protocol          = "HTTP"

  #default_action {
   # type             = "forward"
    #target_group_arn = aws_lb_target_group.prometheus_tg.arn
  #}
#}


/*resource "aws_instance" "ec2_instance" {
  ami                         = "ami-00a929b66ed6e0de6"
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ecs_instance_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  tags = {
    Name = "ECS EC2 Instance"
  }
}*/

