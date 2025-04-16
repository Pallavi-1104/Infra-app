# modules/observability/output.tf
output "prometheus_instance_id" {
  value = aws_instance.prometheus.id
}

output "grafana_instance_id" {
  value = aws_instance.grafana.id
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.ecs_cluster_name
}
