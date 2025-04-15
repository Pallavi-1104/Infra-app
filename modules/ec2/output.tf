# modules/ec2/output.tf
output "asg_name" {
  value = aws_autoscaling_group.ecs_asg.name
}

