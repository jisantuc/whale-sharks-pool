resource "aws_api_gateway_rest_api" "whale_sharks_api" {
  name        = "gatewayWhaleSharksAPI"
  description = "Terraform API Gateway for incoming Slack events to automate outage reporting"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.whale_sharks_api.id
  parent_id   = aws_api_gateway_rest_api.whale_sharks_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.whale_sharks_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "whale_sharks_api_lambda" {
  rest_api_id = aws_api_gateway_rest_api.whale_sharks_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.whale_sharks_api.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.whale_sharks_api.id
  resource_id   = aws_api_gateway_rest_api.whale_sharks_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "whale_sharks_api_lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.whale_sharks_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.whale_sharks_api.invoke_arn
}

resource "aws_api_gateway_deployment" "whale_sharks_api" {
  rest_api_id = aws_api_gateway_rest_api.whale_sharks_api.id

  triggers = {
    redeployment = base64sha256(jsonencode(tolist([aws_api_gateway_resource.proxy.id, aws_api_gateway_method.proxy.id, aws_api_gateway_integration.whale_sharks_api_lambda.id])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  stage_name    = "Production"
  rest_api_id   = aws_api_gateway_rest_api.whale_sharks_api.id
  deployment_id = aws_api_gateway_deployment.whale_sharks_api.id
}

output "base_url" {
  value = aws_api_gateway_deployment.whale_sharks_api.invoke_url
}
