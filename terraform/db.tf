# postgres db

provider "aws" {
  region = var.region
}

resource "aws_instance" "database" {
  ami           = "ami-099e58e6eeeaa8281" # ami-00b21f32c4929a15b
  instance_type = "t2.micro"

  tags = {
    Name = "backend_db"
  }
}

# snowflake db