/*
-------------------------------------------
General AWS Output Configuration
-------------------------------------------
*/

output "aws_region" {
  description = "Region set for AWS"
  value       = var.aws_region
}

output "private_key" {
  description = "EC2 private key."
  value       = tls_private_key.custom_key.private_key_pem
  sensitive   = true
}

output "public_key" {
  description = "EC2 public key."
  value       = tls_private_key.custom_key.public_key_openssh
}

/*
-------------------------------------------
AWS Output Configuration for PostgreSQL Database
-------------------------------------------
*/

output "ec2_ssh_connection_url" {
  value = aws_instance.postgres_db_ec2.public_ip
  description = "Public IP address for the EC2 instance"
}

locals {
  command = "echo \"POSTGRES_EC2_IP_ADDRESS=$(terraform output -raw ec2_ssh_connection_url)\" >> .env"
}

/*
-------------------------------------------
AWS Output Configuration for ECR
-------------------------------------------
*/

provisioner "local-exec" {
  command = "echo POSTGRES_EC2_IP_ADDRESS=${self.repository_url} >> .env"
}

provisioner "local-exec" {
  command = "echo REPOSITORY_URL=${self.repository_url} >> .env"
}

# echo "POSTGRES_EC2_IP_ADDRESS=$(terraform output ec2_ssh_connection_url)" >> .env

# echo "DBT_EC2_IP_ADDRESS=$(terraform output ec2_ssh_connection_url)" >> .env

# echo "DAGSTER_EC2_IP_ADDRESS=$(terraform output ec2_ssh_connection_url)" >> .env

# echo "AIRBYTE_EC2_IP_ADDRESS=$(terraform output ec2_ssh_connection_url)" >> .env

# echo "METABASE_EC2_IP_ADDRESS=$(terraform output ec2_ssh_connection_url)" >> .env