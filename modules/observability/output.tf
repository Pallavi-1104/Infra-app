# modules/observability/output.tf
output "prometheus_instance_id" {
  value = aws_instance.prometheus.id
}

output "grafana_instance_id" {
  value = aws_instance.grafana.id
}

