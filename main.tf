module "vpc" {
  source = "./modules/vpc"
  # pass values as your vpc module expects (if any)
}

module "ec2" {
  source          = "./modules/ec2"
  ami_id          = "ami-0c94855ba95c71c99" # lab AMI (replace if different)
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnets
  private_subnets   = module.vpc.private_subnets
  public_instances  = module.ec2.public_instances
  private_instances = module.ec2.private_instances
  public_sg_id      = module.ec2.public_sg_id
}
