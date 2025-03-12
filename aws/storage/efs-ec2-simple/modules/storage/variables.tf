variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "The CIDR blocks of the subnets in which the EFS will be located"
  type        = list(string)
}

variable "subnet_ids" {
  description = "The IDs of the subnets in which the EFS will be located"
  type        = list(string)
}