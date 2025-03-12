module "network" {
  source = "./modules/network"
}

module "storage" {
  source             = "./modules/storage"
  subnet_cidr_blocks = module.network.private_subnet_cidr_blocks
  subnet_ids         = module.network.private_subnet_ids
  vpc_id             = module.network.vpc_id
}

module "compute" {
  source     = "./modules/compute"
  subnet_ids = module.network.private_subnet_ids
  efs_id     = module.storage.efs_id
}
