variable "availability_zones" {
  description = "List of availability zones with their associated public and private subnets"
  type = list(object({
    name           = string
    private_subnet = object({ cidr_block = string })
    public_subnet  = object({ cidr_block = string })
  }))
  
  default = [
    {
      name           = "us-east-1a"
      private_subnet = { cidr_block = "10.0.1.0/24" }
      public_subnet  = { cidr_block = "10.0.101.0/24" }
    },
    {
      name           = "us-east-1b"
      private_subnet = { cidr_block = "10.0.2.0/24" }
      public_subnet  = { cidr_block = "10.0.102.0/24" }
    }
  ]
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
