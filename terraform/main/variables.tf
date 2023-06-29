variable "region" {
  description = "The region where the infrastructure should be created"
  type        = string
  default     = "us-west-2"
}

variable "aws_availability_zone" {
  type    = string
  default = "us-west-2a"
}

variable "ecs_optimized_ami" { # var.ecs_optimized_ami
  type    = string
  default = "ami-0cbd4a3fa79e3b362"
}

variable "ec2_size" { # var.ec2_size
  type    = string
  default = "t2.medium"
}

# variable "public_key_path" {
#   description = "Path to the public key used for SSH access"
#   type        = string
#   default     = "/Users/oresttokovenko/.ssh/id_rsa.pub"
# }