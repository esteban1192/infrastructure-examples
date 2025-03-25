output "rest_api_id" {
  description = "The ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.api.id
}

output "deployment_id" {
  description = "The ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.deployment.id
}

output "stage_name" {
  description = "The name of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.stage_name
}

output "stage_arn" {
  description = "arn of the api stage"
  value       = aws_api_gateway_stage.stage.arn
}
