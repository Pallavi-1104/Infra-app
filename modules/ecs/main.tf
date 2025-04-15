    # modules/ecs/main.tf
    resource "aws_ecs_cluster" "ecs_cluster" {
      name = "nodejs-mongodb-cluster"
    }

    resource "aws_iam_role" "ecs_tasks_role" {
      name = "ecs-tasks-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Principal = {
              Service = "ecs-tasks.amazonaws.com"
            }
            Effect = "Allow"
            Sid = ""
          }