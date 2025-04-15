# modules/observability/outputs.tf
output "prometheus_instance_id" {
  value = aws_ec2_instance.prometheus.id
}

output "grafana_instance_id" {
  value = aws_ec2_instance.grafana.id
}
