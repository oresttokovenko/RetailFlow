# provider

provider "aws" {
  region = var.region
}

# security group

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # this will allow all IP addresses
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_ssh"
  }
}

# Public and private key to use to login to the EC2 instance

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "tf_key"       
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.ssh_key.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
  file_permission = 400
}

# postgres db

resource "aws_instance" "postgres_db_ec2" {
  ami                    = "ami-0ab193018f3e9351b" # amazon linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  user_data = templatefile("storage/install_postgres.sh", {
    pg_hba_file = templatefile("storage/pg_hba.conf", { allowed_ip = "0.0.0.0/0" }),
  })
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] # attach the security group to the instance

  tags = {
    Name = "backend_db"
  }
}

# Show the public IP of the newly created instance
output "instance_ip_addr" {
  value = aws_instance.postgres_db_ec2.*.public_ip
}

# snowflake db