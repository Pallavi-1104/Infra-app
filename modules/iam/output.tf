output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}

output "iam_role_name" {
  description = "IAM Role Name"
  value       = aws_iam_role.ec2_role.name
}

