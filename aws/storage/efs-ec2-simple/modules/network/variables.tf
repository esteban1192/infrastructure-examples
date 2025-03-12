variable "private_subnets" {
  description = "List of private subnets with CIDR blocks and availability zones"
  type = list(object({
    cidr_block = string
    availability_zone   = string
  }))
  default = [
    { cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a" },
    { cidr_block = "10.0.2.0/24", availability_zone = "us-east-1b" }
  ]
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block of the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}
