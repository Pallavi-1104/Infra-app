# Assume Role Policies (DATA)
data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# EC2 IAM Role
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ec2_attach_policy" {
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn
}

# ECS Execution Role
#resource "aws_iam_role" "ecs_task_execution_role" {
  #name = "ecsTaskExecutionRole"
 # assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
#}

# ECS Task Role
#resource "aws_iam_role" "ecs_task_role" {
 # name = "ecsTaskRole"
  #assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
#}

