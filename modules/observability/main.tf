# modules/observability/main.tf
# Prometheus resources
resource "aws_cloudwatch_log_group" "prometheus_log_group" {
  name = "/aws/prometheus"
}

resource "aws_instance" "prometheus" {
  ami           = "ami-0c55b9dcb338f9877" #  Replace with a Prometheus-ready AMI
  instance_type = "t3.medium"
  subnet_id     = var.subnet_public_1_id
  security_groups = [aws_security_group.ecs_instance_sg.id] # Use the ecs sg
  user_data     = <<EOF
#!/bin/bash
# Install Prometheus
sudo yum install -y prometheus

# Configure Prometheus (basic example)
cat >/etc/prometheus/prometheus.yml <<PROM
global:
  scrape_interval:     15s
  evaluation_interval: 15s
  external_labels:
    job: 'prometheus'
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
  - job_name: 'node'
    static_configs:
    - targets: ['10.0.1.10:9100','10.0.1.11:9100'] # Add your node ips
PROM

# Start Prometheus
sudo systemctl start prometheus
sudo systemctl enable prometheus
EOF
  tags = {
    Name = "Prometheus Server"
  }
}

# Grafana resources
resource "aws_cloudwatch_log_group" "grafana_log_group" {
  name = "/aws/grafana"
}

resource "aws_instance" "grafana" {
  ami           = "ami-0c55b9dcb338f9877" # Replace with a Grafana-ready AMI
  instance_type = "t3.medium"
  subnet_id     = var.subnet_public_2_id
  security_groups = [aws_security_group.ecs_instance_sg.id] # Use the ecs sg
  user_data     = <<EOF
#!/bin/bash
# Install Grafana
sudo yum install -y grafana

# Start Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
EOF
  tags = {
    Name = "Grafana Server"
  }
}

# Allow Prometheus to scrape metrics from Node.js
resource "aws_security_group_rule" "allow_prometheus_nodejs" {
  type             = "ingress"
  from_port       = 9464  #  The port where Node.js exposes metrics (defined in Node.js code)
  to_port         = 9464
  protocol        = "tcp"
  cidr_blocks      = ["0.0.0.0/0"] #  Restrict this in production!
  security_group_id = aws_security_group.ecs_instance_sg.id
}


