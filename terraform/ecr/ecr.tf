/*
-------------------------------------
Provider Definition

This block of code establishes AWS as the cloud platform we'll be using
-------------------------------------
*/

provider "aws" {
  region = var.region
}

/*
-------------------------------------------
AWS ECR Configuration

Creating ECR Repository to store Docker containers
-------------------------------------------
*/

resource "aws_ecr_repository" "ecr" {
  name                 = "retailflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
