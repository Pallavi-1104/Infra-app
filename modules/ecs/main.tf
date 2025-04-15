# modules/ecs/main.tf
# (Add this missing resource)
resource "aws_iam_role" "ecs_tasks_role" {
  name = "ecs-tasks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}
