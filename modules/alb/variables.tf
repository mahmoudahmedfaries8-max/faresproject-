variable "vpc_id" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_instances" {
  type = list(string)
}

variable "private_instances" {
  type = list(string)
}

variable "public_sg_id" {
  type        = string
  description = "ID of the public security group to attach to the ALB"
}
