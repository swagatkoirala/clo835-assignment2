variable "prefix" {
  description = "resource names prefixes"
  type        = string
}

variable "default_tags" {
  description = "Default tags for resources"
  type        = map(string)
}

variable "vpc" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet" {
  description = "List of CIDR blocks for public subnet"
  type        = string
}