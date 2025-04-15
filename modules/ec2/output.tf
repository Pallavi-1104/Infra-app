# modules/ec2/outputs.tf
output "asg_name" {
  value = aws_autoscaling_group.ecs_asg.name
}