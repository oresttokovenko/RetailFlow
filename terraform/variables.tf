variable "region" {
  description = "The region where the infrastructure should be created"
  type        = string
  default     = "us-west-2"
}

variable "aws_availability_zone" {
  type    = string
  default = "us-west-2a"
}

# variable "public_key_path" {
#   description = "Path to the public key used for SSH access"
#   type        = string
#   default     = "/Users/oresttokovenko/.ssh/id_rsa.pub"
# }