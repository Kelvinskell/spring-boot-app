# Create A VPC
module "vpc" {
  source = "./modules/vpc"

  env = var.env
  app = var.app
  region = var.region
}

# Create ALB
module "alb" {
  source = "./modules/alb"

  env = var.env
  app = var.app
  public_subnets = flatten([module.vpc.public_subnets[*]])
  vpc_id = module.vpc.vpc_id
  alb_sg = module.security_groups.alb_sg
}
