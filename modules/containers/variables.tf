variable "ecs_cluster_name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}

variable "execution_role_arn" {}
variable "task_role_arn" {}