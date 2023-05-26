## Create EC2 instance with PostgresDB

provider "aws" {
  region = "us-west-2"
  access_key = "<aws-access-key>"
  secret_key = "<aws-secret-key>"
}

resource "aws_instance" "example" {
  ami           = "<ami-id>"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}


## Create EC2 instance with Airbyte

provider "aws" {
  region = "us-west-2"
  access_key = "<aws-access-key>"
  secret_key = "<aws-secret-key>"
}

resource "aws_instance" "example" {
  ami           = "<ami-id>"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}


## Create Snowflake instance

provider "snowflake" {
  account  = "..." # required if not using profile. Can also be set via SNOWFLAKE_ACCOUNT env var
  username = "..." # required if not using profile or token. Can also be set via SNOWFLAKE_USER env var
  password               = "..."
  oauth_access_token     = "..."
  private_key_path       = "..."
  private_key            = "..."
  private_key_passphrase = "..."
  oauth_refresh_token    = "..."
  oauth_client_id        = "..."
  oauth_client_secret    = "..."
  oauth_endpoint         = "..."
  oauth_redirect_url     = "..."

  // optional
  region    = "..." # required if using legacy format for account identifier
  role      = "..."
  host      = "..."
  warehouse = "..."
}


provider snowflake {
  profile = "securityadmin"
}

## Create EC2 instance with dbt and Dagster

provider "aws" {
  region = "us-west-2"
  access_key = "<aws-access-key>"
  secret_key = "<aws-secret-key>"
}

resource "aws_instance" "example" {
  ami           = "<ami-id>"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}

# Create EC2 instance with Metabase

provider "aws" {
  region = "us-west-2"
  access_key = "<aws-access-key>"
  secret_key = "<aws-secret-key>"
}

resource "aws_instance" "example" {
  ami           = "<ami-id>"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}