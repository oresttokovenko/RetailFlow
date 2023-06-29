variable "region" {
  description = "The region where the infrastructure should be created"
  type        = string
  default     = "us-west-2"
}

variable "aws_availability_zone" {
  type    = string
  default = "us-west-2a"
}