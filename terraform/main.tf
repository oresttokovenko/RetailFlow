## Create Lambda function

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs16.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

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