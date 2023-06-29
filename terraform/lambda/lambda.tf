# provider
provider "aws" {
  region = var.region
}

/*
-------------------------------------------
Setting up AWS CloudWatch to invoke a specified AWS Lambda function every three minutes.

-------------------------------------------
*/

resource "aws_cloudwatch_event_rule" "every_three_minutes" {
  name                = "every-three-minutes"
  description         = "Fires every three minutes"
  schedule_expression = "rate(3 minutes)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda_every_three_minutes" {
  rule      = aws_cloudwatch_event_rule.every_three_minutes.name
  target_id = "invokeLambda"
  arn       = aws_lambda_function.fake_data_generator.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fake_data_generator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_three_minutes.arn
}

/*
-------------------------------------------
Creating a Lambda Function with IAM Role in AWS

-------------------------------------------
*/

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_function" "fake_data_generator" {
  filename      = "../../generate/lambda.zip"
  function_name = "fakeDataGenerator"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "generate_fake_data.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.10"
}
