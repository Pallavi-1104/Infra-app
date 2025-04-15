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

module "network" {
  source = "./modules/network"
}

module "ec2" {
  source    = "./modules/ec2"
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnet_public_1_id
  subnet_public_1_id = module.network.subnet_public_1_id
  subnet_public_2_id = module.network.subnet_public_2_id
}

module "ecs" {
  source            = "./modules/ecs"
  vpc_id            = module.network.vpc_id
  subnet_public_1_id = module.network.subnet_public_1_id
  subnet_public_2_id = module.network.subnet_public_2_id
}

module "observability" {
  source            = "./modules/observability"
  vpc_id            = module.network.vpc_id
  subnet_public_1_id = module.network.subnet_public_1_id
  subnet_public_2_id = module.network.subnet_public_2_id
}

