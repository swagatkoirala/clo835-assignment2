# All Outputs for public subnet and vpc
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "public_route_table" {
  value = aws_route_table.public_route_table.id
}
