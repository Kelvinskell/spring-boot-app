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
  lambda_iam_role = module.rds.lambda_iam_role
}

module "rds" {
  source = "./modules/rds"

  env = var.env
  app = var.app
  rds_sg = module.security_groups.RDS-sg_id
  db_username = var.db_username
  db_password = var.db_password
  private_subnet_ids = flatten([module.vpc.private_subnets[*]])
  lambda_sg = module.security_groups.lambda_sg_id
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
  rds_instance = module.rds.rds_instance
}

module "monitoring" {
  source = "./modules/monitoring"

  env = var.env
  app = var.app
  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  region = var.region
  # Set to false if you want to get notified each time a task fails. 
  # Set to true to get notified for only one ecs task failure. You won't be notified for subsequent task failures.
  single_notification = false 
  sns_email_address = var.sns_email_address
  ecs_cluster_arn = module.ecs.ecs_cluster_arn
}

# Enable ECS Cluster Auoscaling
module "ecs-service-autoscaling" {
  source  = "cn-terraform/ecs-service-autoscaling/aws"
  version = "1.0.10"

  ecs_service_name  = module.ecs.ecs_service_name
  ecs_cluster_name  = module.ecs.ecs_cluster_name
  name_prefix = "${var.env}-${var.app}"
  cooldown = 60
  max_cpu_threshold = "85"
  scale_target_min_capacity = 1
  scale_target_max_capacity = 5

  tags = {
    Name = "${var.app}-ecs-autoscaling-service-${var.env}"
    Environment = var.env
    app = var.app
  }
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