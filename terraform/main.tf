/*
-------------------------------------
Provider Definition

This block of code establishes AWS as the cloud platform we'll be using
-------------------------------------
*/

provider "aws" {
  region = var.region
}

provider "snowflake" {
  account = "your_snowflake_account"
  username = "your_snowflake_username"
  password = "your_snowflake_password"
  role = "ACCOUNTADMIN"
}

/*
-------------------------------------
Security Group Definition

This block of code creates a security group 
that allows HTTP, HTTPS, and SSH traffic
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

resource "temp" "example" {
  count = var.create_instance ? 1 : 0
}


/*
-------------------------------------------
AWS Instance Configuration for Dagster and dbt

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as DAGSTER_DBT_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "temp" "example" {
  count = var.create_instance ? 1 : 0
}


/*
-------------------------------------------
AWS Instance Configuration for Metabase

This block of code creates an AWS EC2 instance, using a specific Amazon Linux 2023 AMI, and the instance type is 't2.micro'. 
An existing key pair is attached to this instance for secure SSH access. 

Following the resource creation, the public IP address is appended to .env as METABASE_EC2_IP_ADDRESS
-------------------------------------------
*/

resource "temp" "example" {
  count = var.create_instance ? 1 : 0
}


/*
-------------------------------------------
Creating a Lambda Function with IAM Role in AWS

1. Packs the source code present in the 'package' directory into a ZIP file. This ZIP file is used as deployment package for the Lambda function.

2. Defines an IAM Role named 'lambda_exec_role' that our Lambda function will assume. The 'assume_role_policy' allows the Lambda service to assume this role.

3. Attaches the AWS managed 'AWSLambdaBasicExecutionRole' policy to 'lambda_exec_role'. This policy grants the necessary permissions for Lambda to write logs to CloudWatch.

4. Creates a new Lambda function named 'fakeDataGenerator'. The function uses Python 3.8 runtime and the deployment package created earlier. It assumes the 'lambda_exec_role' and defines an environment variable 'ENV_VARIABLE_NAME' with a value 'value'.

5. It sets the 'handler' for the function as 'generate_fake_data.lambda_handler'. This corresponds to the 'lambda_handler' function in the 'generate_fake_data' file of the deployment package.

-------------------------------------------
*/

# provider
provider "aws" {
  region = var.region
}

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/package"
#   output_path = "${path.module}/package.zip"
# }

resource "aws_lambda_function" "fake_data_generator" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "fakeDataGenerator"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "generate_fake_data.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
      ENV_VARIABLE_NAME = "value"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

/*
-------------------------------------------
AWS ECS Configuration

EC2 Launch Type - Manual management: You provision and manage your own EC2 instances and add them to your ECS cluster. You need to consider the instance types, sizes, number of instances, etc., based on your workloads. In this case, you need to provision the EC2 instances before ECS tasks can be run on them.
-------------------------------------------
*/

resource "aws_ecs_task_definition" "ecs_task" {
  family                = "service"
  container_definitions = file("task-definitions.json")
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  depends_on = [aws_instance.ecs_instance1, aws_instance.ecs_instance2, aws_instance.ecs_instance3, aws_instance.ecs_instance4, aws_instance.ecs_instance5]
}