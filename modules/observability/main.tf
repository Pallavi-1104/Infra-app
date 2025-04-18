variable "ecs_instance_sg_id" {
  description = "SG for EC2 used by ECS"
  type        = string
}

resource "aws_instance" "prometheus" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_public_1_id
  associate_public_ip_address = true
  security_groups = [var.ecs_instance_sg_id]
  tags = {
    Name = "Prometheus"
  }
}

resource "aws_instance" "grafana" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t3.micro"
  subnet_id     = var.subnet_public_2_id
  associate_public_ip_address = true
  security_groups = [var.ecs_instance_sg_id]
  tags = {
    Name = "Grafana"
  }
}

resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "my-ecs-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", "my-ecs-cluster" ]
          ],
          period = 300,
          stat   = "Average",
          region = "us-east-1",
          title  = "ECS Cluster CPU Utilization"
        }
      }
    ]
  })
}



resource "aws_security_group_rule" "allow_prometheus_nodejs" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  security_group_id = var.ecs_instance_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
}










