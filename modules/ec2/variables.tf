variable "ami_id" {
  type        = string
  description = "AMI ID provided by lab"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

