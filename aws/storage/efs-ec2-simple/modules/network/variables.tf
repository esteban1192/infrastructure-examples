variable "availability_zones" {
  description = "Map of availability zones with their associated public and private subnets"
  type = map(object({
    private_subnet_cidr = string
    public_subnet_cidr  = string
  }))

  default = {
    "us-east-1a" = {
      private_subnet_cidr = "10.0.1.0/24"
      public_subnet_cidr  = "10.0.101.0/24"
    },
    "us-east-1b" = {
      private_subnet_cidr = "10.0.2.0/24"
      public_subnet_cidr  = "10.0.102.0/24"
    }
  }
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
