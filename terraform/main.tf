# Create A VPC
module "vpc" {
  source = "./modules/vpc"

  env = var.env
  app = var.app
  region = var.region
}
