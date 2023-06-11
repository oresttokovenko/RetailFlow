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

It uses a user data script 'install_postgres.sh' to set up PostgreSQL on the instance, and the 'pg_hba.conf' file allows 
all IPs to connect to the database (you may want to restrict this in a production environment). 

The instance is attached to a security group 'allow_ssh' that should permit SSH access. 

The instance is tagged with the name 'backend_db'. 

Following the resource creation, an output is defined to show the public IP address of the newly created instance.
-------------------------------------------
*/

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

output "instance_ip_addr" {
  value = aws_instance.postgres_db_ec2.*.public_ip
}

/*
-------------------------------------------
Configuration and Resource Creation for Snowflake 

The role for the account is set as 'ACCOUNTADMIN', a role named 'EXAMPLE_ROLE' is created on Snowflake, a new database 'EXAMPLE_DATABASE' is also created on Snowflake, and a schema named 'EXAMPLE_SCHEMA' is then created within the database, with an attached comment that describes its purpose. 

Finally, USAGE privileges on this schema are granted to 'EXAMPLE_ROLE'. 
This allows the role to access and interact with the schema.
-------------------------------------------
*/

resource "snowflake_role" "example_role" {
  name = "EXAMPLE_ROLE"
}

resource "snowflake_database" "example_database" {
  name = "EXAMPLE_DATABASE"
}

resource "snowflake_schema" "example_schema" {
  name = "EXAMPLE_SCHEMA"
  database = snowflake_database.example_database.name
  comment = "A schema for our example data"
}

resource "snowflake_schema_grant" "example_role_schema" {
  schema_name = snowflake_schema.example_schema.name
  database_name = snowflake_database.example_database.name
  privilege = "USAGE"
  roles = [snowflake_role.example_role.name]
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

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = "${path.module}/package.zip"
}

resource "aws_lambda_function" "fake_data_generator" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "fakeDataGenerator"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "generate_fake_data.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.8"

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
