variable "awsAccountId" {
  type = string
}

variable "awsRegion" {
  type = string
  default = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "LambdaMoviesRole" {
  name = "LambdaMoviesRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaMoviesRoleDyanmoDBPolicy"{
  name = "LambdaMoviesRoleDyanmoDBPolicy"
  role = aws_iam_role.LambdaMoviesRole.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.MovieCollectionDB.arn}"
    }
  ]
}
EOF
}

resource "aws_dynamodb_table" "MovieCollectionDB" {
  name           = "MovieCollection"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_lambda_function" "GetMovieFunction" {
  filename = "lambdas.zip"
  source_code_hash = filebase64sha256("lambdas.zip")
  function_name = "GetMovie"
  handler = "src/listMovies.handler"
  runtime = "nodejs12.x"
  role = aws_iam_role.LambdaMoviesRole.arn
}

resource "aws_lambda_function" "PostMovieFunction" {
  filename = "lambdas.zip"
  source_code_hash = filebase64sha256("lambdas.zip")
  function_name = "PostMovie"
  handler = "src/postMovie.handler"
  runtime = "nodejs12.x"
  role = aws_iam_role.LambdaMoviesRole.arn
}

resource "aws_api_gateway_rest_api" "AwsLearningMovieAPI" {
  name        = "AwsLearningMovieAPI"
  description = "API created to learn about AWS services"
}

resource "aws_api_gateway_resource" "MoviesResource" {
  rest_api_id = aws_api_gateway_rest_api.AwsLearningMovieAPI.id
  parent_id   = aws_api_gateway_rest_api.AwsLearningMovieAPI.root_resource_id
  path_part   = "movies"
}

resource "aws_api_gateway_method" "GetMoviesRoute" {
  rest_api_id   = aws_api_gateway_rest_api.AwsLearningMovieAPI.id
  resource_id   = aws_api_gateway_resource.MoviesResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "GetMoviesLambdaIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.AwsLearningMovieAPI.id
  resource_id             = aws_api_gateway_resource.MoviesResource.id
  http_method             = aws_api_gateway_method.GetMoviesRoute.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.GetMovieFunction.invoke_arn

}

resource "aws_lambda_permission" "GetMoviesLambdaPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GetMovieFunction.arn
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.awsRegion}:${var.awsAccountId}:${aws_api_gateway_rest_api.AwsLearningMovieAPI.id}/*/${aws_api_gateway_method.GetMoviesRoute.http_method}${aws_api_gateway_resource.MoviesResource.path}"
}

resource "aws_api_gateway_method" "PostMovieRoute" {
  rest_api_id   = aws_api_gateway_rest_api.AwsLearningMovieAPI.id
  resource_id   = aws_api_gateway_resource.MoviesResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "PostMovieLambdaIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.AwsLearningMovieAPI.id
  resource_id             = aws_api_gateway_resource.MoviesResource.id
  http_method             = aws_api_gateway_method.PostMovieRoute.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.PostMovieFunction.invoke_arn
  
}

resource "aws_lambda_permission" "PostMovieLambdaPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.PostMovieFunction.arn
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.awsRegion}:${var.awsAccountId}:${aws_api_gateway_rest_api.AwsLearningMovieAPI.id}/*/${aws_api_gateway_method.PostMovieRoute.http_method}${aws_api_gateway_resource.MoviesResource.path}"
}