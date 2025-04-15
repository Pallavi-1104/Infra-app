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

# main.tf
module "ecs_cluster" {
  source              = "./modules/ecs"
  vpc_id              = module.network.vpc_id
  subnet_public_1_id  = module.network.subnet_public_1_id
  subnet_public_2_id  = module.network.subnet_public_2_id
}

module "general_ec2" {
  source        = "./modules/ec2"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.subnet_public_1_id
  name_prefix   = "general"
}

module "app_ec2" {
  source = "./modules/ec2"

  ami_id            = data.aws_ssm_parameter.ecs_ami.value
  instance_type     = "t3.micro"
  instance_profile  = module.iam.instance_profile_name
  security_group_id = module.network.ecs_instance_sg_id
  name_prefix       = "app"
}


module "observability" {
  source              = "./modules/observability"
  vpc_id              = module.network.vpc_id
  subnet_public_1_id  = module.network.subnet_public_1_id
  subnet_public_2_id  = module.network.subnet_public_2_id
  ecs_instance_sg_id  = module.general_ec2.ecs_instance_sg_id
}
