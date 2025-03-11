variable "instances_count" {
  type    = number
  default = 2
}

variable "instances_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type        = string
  description = "the id of the subnet in which the ec2 instances will be located"
}

variable "efs_id" {
  type        = string
  description = "the id of the efs to be mounted on the instances"
}