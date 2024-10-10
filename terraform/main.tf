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
  alb_sg = module.security_groups.Alb-sg_id
}

module "security_groups" {
  source = "./modules/security_groups"

  app = var.app
  env = var.env
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source = "./modules/rds"

  env = var.env
  app = var.app
  rds_sg = module.security_groups.RDS-sg_id
  db_username = var.db_username
  db_password = var.db_password
}

module "ecs" {
  source = "./modules/ecs"

  azs = ["${var.region}a", "${var.region}b"]
  tg_arn = module.alb.tg_arn
  private_subnets = flatten([module.vpc.private_subnets[*]])
  ecs_sg = module.security_groups.ECS-sg_id
  app = var.app
  env = var.env
  region = var.region
  image_name = var.image_name
  mysql_endpoint = module.rds.rds_endpoint
  mysql_password = module.rds.mysql_password
  mysql_username = module.rds.mysql_username
}

module "monitoring" {
  source = "./modules/monitoring"

  env = var.env
  app = var.app
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  region = var.region
}

# Create a resource group
resource "aws_resourcegroups_group" "app_resources" {
  name = format("%s-%s-resources", var.env, var.app)

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Environment"
          Values = [var.env]
        },
        {
          Key    = "app"
          Values = [var.app]
        }
      ]
    })
  }
}
