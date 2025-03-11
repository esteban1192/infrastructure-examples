variable "private_subnet_az" {
  description = "The az to locate the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "The cidr block of the vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The cidr block of the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "The cidr block of the private subnet subnet"
  type        = string
  default     = "10.0.1.0/24"
}