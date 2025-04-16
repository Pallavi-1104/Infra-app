resource "aws_ecs_task_definition" "nodejs_mongo" {
  family                   = "nodejs-mongo"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = jsonencode([
    {
      name      = "mongo"
      image     = "mongo"
      essential = true
      portMappings = [{
        containerPort = 27017
        hostPort      = 27017
      }]
      mountPoints = [{
        containerPath = "/data/db"
        sourceVolume  = "mongo_data"
      }]
    },
    {
      name      = "nodejs"
      image     = "your-node-app-image" # replace with your image
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
      environment = [{
        name  = "MONGO_URL"
        value = "mongodb://mongo:27017"
      }]
    }
  ])

  volume {
    name = "mongo_data"
    host_path {
      path = "/mnt/efs/mongo" # could be local disk or EFS
    }
  }

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}


resource "aws_ecs_service" "node_mongo_service" {
  name            = "node-mongo-service"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.nodejs_mongo.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  }
}
