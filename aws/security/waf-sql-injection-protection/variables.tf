variable "region" {
  description = "The region to launch resources"
  type        = string
  default     = "us-east-1"
}

variable "accountId" {
  description = "The id of the account to deploy resources"
  type        = string
}