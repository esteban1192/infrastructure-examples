module "network" {
  source = "./modules/network"
}

module "storage" {
  source            = "./modules/storage"
  subnet_cidr_block = module.network.private_subnet_cidr_block
  subnet_id         = module.network.private_subnet_id
  vpc_id            = module.network.vpc_id
}

module "compute" {
  source    = "./modules/compute"
  subnet_id = module.network.private_subnet_id
  efs_id    = module.storage.efs_id
}
