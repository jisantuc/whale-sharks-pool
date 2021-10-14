resource "aws_lambda_function" "whale_sharks_api" {
  filename         = "../dist/package.zip"
  source_code_hash = filebase64sha256("../dist/package.zip")
  function_name    = "funcWhaleSharksAPI"
  description      = "Whale sharks API"
  role             = resource.aws_iam_role.whale_sharks_api_role.arn
  runtime          = "nodejs14.x"
  handler          = "index.backend.handler"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      AIRTABLE_KEY = var.airtable_key
    }
  }
}

resource "aws_lambda_permission" "api_gateway_whale_sharks_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.whale_sharks_api.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.whale_sharks_api.execution_arn}/*/*"
}

data "aws_iam_policy_document" "lambda_automated_outage_reporting_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricData",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "whale_sharks_api_role" {
  name = "LambdaIAMRole"

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

resource "aws_iam_role_policy_attachment" "whale_sharks_api_execution_role" {
  role       = aws_iam_role.whale_sharks_api_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
