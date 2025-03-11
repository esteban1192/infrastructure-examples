variable "vpc_id" {
    description = "The VPC ID"
    type = string
}

variable "subnet_cidr_block" {
    description = "The cidr block of the subnet in which the efs will be located"
    type = string
}

variable "subnet_id" {
    description = "The ID of the subnet in which the efs will be located"
    type = string
}