module "environment" {
  source        = "../module"
  vpc           = var.vpc
  public_subnet = var.public_subnet
  prefix        = var.prefix
  default_tags  = var.default_tags
}
