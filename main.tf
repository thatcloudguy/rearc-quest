terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

module "aws_vpc" {
  source                  = "cloudposse/vpc/aws"
  version                 = "2.0.0"
  namespace               = "tcg"
  stage                   = "dev"
  name                    = "quest"
  ipv4_primary_cidr_block = "10.0.0.0/16"

  assign_generated_ipv6_cidr_block = false
}
module "aws_vpc_subnets" {
  source             = "cloudposse/dynamic-subnets/aws"
  version            = "2.1.0"
  namespace          = "tcg"
  stage              = "dev"
  name               = "quest"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_id             = module.aws_vpc.vpc_id
  igw_id             = [module.aws_vpc.igw_id]
  ipv4_cidr_block    = [module.aws_vpc.vpc_cidr_block]
}

module "aws_fargate" {
  source          = "./modules/aws_fargate"
  image           = "571218764671.dkr.ecr.us-west-2.amazonaws.com/quest:latest"
  root_domain     = "thatcloudadventure.com"
  region          = var.region
  vpc_id          = module.aws_vpc.vpc_id
  public_subnets  = module.aws_vpc_subnets.public_subnet_ids
  private_subnets = module.aws_vpc_subnets.private_subnet_ids
  depends_on      = [module.aws_vpc.vpc_id, module.aws_vpc_subnets.public_subnet_ids, module.aws_vpc_subnets.private_subnet_ids]
}
