provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc
  instance_tenancy = "default"
  tags             = { "Name" = "My VPC" }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet
  tags              = { "Name" = "Public Subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = { "Name" = "My IGW" }
}


# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { "Name" = "Public Route Table" }
}

# Public Route Tables Association
resource "aws_route_table_association" "public_route_table_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}