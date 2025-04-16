# modules/ec2/outputs.tf
#output "instance_id" {
 # value = aws_instance.ec2_instance.id
#}

output "ecs_instance_sg_id" {
  value = aws_security_group.ecs_instance_sg.id
}

output "asg_name" {
  value = aws_autoscaling_group.ecs_asg.name
}
