variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs in which the EC2 instances will be located"
}

variable "efs_id" {
  type        = string
  description = "the id of the efs to be mounted on the instances"
}