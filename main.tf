# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Network module
module "network" {
  source = "./modules/network"
}

module "general_ec2" {
  source = "./modules/ec2"

  vpc_id             = module.network.vpc_id
  subnet_id          = module.network.subnet_public_1_id

  subnet_public_1_id = module.network.subnet_public_1_id
  subnet_public_2_id = module.network.subnet_public_2_id
  ecs_cluster_id     = module.ecs_cluster.ecs_cluster_id
}

# App EC2 (used with ECS etc.)
module "app_ec2" {
  source = "./modules/ec2"

  vpc_id             = module.network.vpc_id
  subnet_id          = module.network.subnet_public_1_id

  subnet_public_1_id = module.network.subnet_public_1_id
  subnet_public_2_id = module.network.subnet_public_2_id
  ecs_cluster_id     = module.ecs_cluster.ecs_cluster_id
}

# Observability module (e.g., Prometheus, Grafana)
module "observability" {
  source             = "./modules/observability"
  vpc_id             = module.network.vpc_id
  subnet_public_1_id = module.network.subnet_public_1_id
  subnet_public_2_id = module.network.subnet_public_2_id
}
