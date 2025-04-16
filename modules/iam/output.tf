output "iam_role_name" {
  value = aws_iam_role.this.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
