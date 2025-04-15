# modules/observability/main.tf (add SG reference via variable)
variable "ecs_instance_sg_id" {
  description = "SG for EC2 used by ECS"
  type        = string
}

resource "aws_instance" "prometheus" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_public_1_id
  security_groups = [var.ecs_instance_sg_id]
  tags = {
    Name = "Prometheus"
  }
}

resource "aws_instance" "grafana" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_public_2_id
  security_groups = [var.ecs_instance_sg_id]
  tags = {
    Name = "Grafana"
  }
}

resource "aws_security_group_rule" "allow_prometheus_nodejs" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  security_group_id = var.ecs_instance_sg_id
  cidr_blocks       = ["0.0.0.0/0"]
}

