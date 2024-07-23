terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

// Adding the providers
provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

// Creating the IAM role
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

// Attaching thr Iam policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// creating the lambda func
resource "aws_lambda_function" "my_lambda" {
  function_name    = "my_test_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.8"
  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  // create a new version when the function is updated
  publish = true 
}

// Creating a Lambda function alias
resource "aws_lambda_alias" "my_lambda_alias" {
  name             = "production"
  function_name    = aws_lambda_function.my_lambda.function_name
  function_version = aws_lambda_function.my_lambda.version
}

// Creating IAM role for eventbridge role
resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge_lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })
}

// Applying policy for above IAM role
resource "aws_iam_role_policy_attachment" "eventbridge_lambda_policy" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

// creating the eventbridge schedules
resource "aws_scheduler_schedule" "my_schedule" {
  name        = "my-schedule"
  description = "Fires every day"
  group_name  = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "rate(1 day)"
  target {
    arn      = aws_lambda_alias.my_lambda_alias.arn
    role_arn = aws_iam_role.eventbridge_role.arn
  }
}


// giving permision for eventbridge to invoke lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  qualifier     = aws_lambda_alias.my_lambda_alias.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.my_schedule.arn
}


// creating the eventbridge schedule using cloud watch rules
/* resource "aws_cloudwatch_event_rule" "my_schedule" {
  name                = "daily-schedule"
  description = "Fires every day"
  schedule_expression = "rate(1 day)"
} */


// defining eventbridge target
/* resource "aws_cloudwatch_event_target" "my_target" {
  rule      = aws_cloudwatch_event_rule.my_schedule.name
  target_id = "my_lambda"
  arn       = aws_lambda_function.my_lambda.arn
} */