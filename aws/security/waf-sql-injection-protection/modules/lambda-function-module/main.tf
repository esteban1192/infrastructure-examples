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

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/layer/lambda_layer_payload.zip"
  layer_name = "sqlite3_layer"

  compatible_runtimes = ["nodejs22.x"]
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "${var.function_name}_logs"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda.mjs"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda.handler"
  runtime          = "nodejs22.x"
  filename         = "lambda_function.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  layers = [ aws_lambda_layer_version.lambda_layer.arn ]
}