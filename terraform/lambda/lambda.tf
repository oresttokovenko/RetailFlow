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