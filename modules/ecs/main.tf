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
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_role_policy_attachment" {
  role_name = aws_iam_role.ecs_tasks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSFullAccess" # Replace
}

resource "aws_ecs_task_definition" "mongodb_task_definition" {
  family                   = "mongodb-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_role.arn

  container_definitions = jsonencode([
    {
      name      = "mongodb"
      image     = "mongo:latest"
      portMappings = [
        {
          containerPort = 27017
          hostPort      = 27017
        }
      ]
      mountPoints = [
        {
          containerPath = "/data/db"
          sourceVolume  = "mongodb-data-volume"
          readOnly      = false
        }
      ]
      healthCheck = {
        command = ["CMD-SHELL", "mongosh --eval 'db.runCommand({ ping: 1 }).ok'"]
        interval = 30
        timeout = 10
        retries = 3
        startPeriod = 10
      }
      logging = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/mongodb",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "mongodb"
        }
      }
    }
  ])
  volume {
    name = "mongodb-data-volume"
    host_path {
      path = "/mnt/data/mongodb"
    }
  }
}

resource "aws_ecs_task_definition" "nodejs_app_task_definition" {
  family                   = "nodejs-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_role.arn

  container_definitions = jsonencode([
    {
      name      = "nodejs-app"
      image     = "node:18-alpine"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "MONGODB_URI"
          value = "mongodb://mongodb:27017/mydb"
        },
      ]
      workingDir = "/app"
      command = ["node", "server.js"]
      logging = {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/nodejs-app",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "nodejs-app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "mongodb_service" {
  name            = "mongodb-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.mongodb_task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"
  placement_constraints {
    type   = "awshost"
    expression = "attribute:ecs.availability-zone == us-east-1a"
  }
  depends_on = [aws_volume_attachment.mongodb_volume_attachment]
}

resource "aws_ecs_service" "nodejs_app_service" {
  name            = "nodejs-app-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.nodejs_app_task_definition.arn
  desired_count   = 1
  launch_type     = "EC2"
    load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "nodejs-app"
    container_port = 3000
  }
}

resource "aws_lb" "load_balancer" {
  name               = "nodejs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [var.subnet_public_1_id, var.subnet_public_2_id]
}

resource "aws_lb_target_group" "target_group" {
  name        = "nodejs-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
    health_check {
    path = "/"
    port = "3000"
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

output "load_balancer_dns" {
  value = aws_lb.load_balancer.dns_name
}
