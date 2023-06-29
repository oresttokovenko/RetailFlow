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
-------------------------------------
Security Group Definition

This block of code creates a security group 
that allows HTTP, HTTPS, and SSH traffic from any IP address
-------------------------------------
*/

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

/*
-------------------------------------------
Creating an AWS Key Pair and Saving Locally

This block of code creates a private TLS key, an AWS key pair, and a local file containing the private key. 

1. A private key is generated using the TLS provider, with the RSA algorithm and a key size of 4096 bits.

2. An AWS key pair is then created. The key name is set to "tf_key", and the public key is set to the OpenSSH representation
   of the previously generated private key.

3. Lastly, a local file named "tf_key.pem" is created with the contents of the PEM representation of the private key. 
   The file permission is set to 400 (owner read-only), adhering to SSH private key file permissions best practices.
-------------------------------------------
*/

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


/*
-------------------------------------------
AWS Instance Configuration for PostgreSQL Database

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as POSTGRES_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "aws_instance" "postgres_db_ec2" {
  ami                    = "ami-0ab193018f3e9351b" # amazon linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] # attach the security group to the instance
}

/*
-------------------------------------------
AWS Instance Configuration for Airbyte

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as AIRBYTE_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "aws_instance" "airbyte_ec2" {
  ami                    = "ami-0ab193018f3e9351b" # amazon linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] # attach the security group to the instance

  user_data = file("${path.module}/ingestion/airbyte/run_airbyte.sh")
}



/*
-------------------------------------------
AWS Instance Configuration for Dagster

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as DAGSTER_DBT_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "aws_instance" "dagster_ec2" {
  ami                    = "ami-0ab193018f3e9351b" # amazon linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] # attach the security group to the instance
}

/*
-------------------------------------------
AWS Instance Configuration for dbt

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as DAGSTER_DBT_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "aws_instance" "dbt_ec2" {
  ami                    = "ami-0ab193018f3e9351b" # amazon linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] # attach the security group to the instance
}


/*
-------------------------------------------
AWS Instance Configuration for Metabase

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as METABASE_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "aws_instance" "metabase_ec2" {
  ami                    = "ami-0ab193018f3e9351b" # amazon linux 2023 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id] # attach the security group to the instance
}
/*
-------------------------------------------
AWS ECS Configuration

EC2 Launch Type - Manual management: Provision and manage your own EC2 instances and add them to your ECS cluster. You need to consider the instance types, sizes, number of instances, etc., based on your workloads. In this case, you need to provision the EC2 instances before ECS tasks can be run on them.
-------------------------------------------
*/

resource "aws_ecs_task_definition" "ecs_task" {
  family                = "service"
  container_definitions = file("task-definitions.json")
}

resource "aws_ecs_service" "container_orchestration" {
  name            = "ecs_container_orchestration"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  depends_on = [aws_instance.postgres_db_ec2, aws_instance.airbyte_ec2, aws_instance.dbt_dagster_ec2, aws_instance.metabase_ec2]
}