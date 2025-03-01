# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Swagat Koirala",
    "Stack" = "Development Network"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# VPC CIDR range
variable "vpc" {
  default     = "10.0.0.0/16"
  type        = string
  description = "VPC CIDR block for the environment."
}

variable "prefix" {
  default = "assignment1"
  type    = string
}

# Provision public subnets in custom VPC
variable "public_subnet" {
  default     = "10.0.1.0/24"
  type        = string
  description = "Public Subnet CIDRs"
}