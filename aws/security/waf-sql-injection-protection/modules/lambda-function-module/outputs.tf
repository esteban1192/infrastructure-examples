output "lambda_function_invoke_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda.invoke_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}