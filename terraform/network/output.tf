output "vpc_id" {
  value = module.environment.vpc_id
}

output "public_subnet_id" {
  value = module.environment.public_subnet_id
}

output "route_table" {
  value = module.environment.public_route_table
}