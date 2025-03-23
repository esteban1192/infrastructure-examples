output "rest_api_id" {
  value = module.api_gateway.rest_api_id
}

output "deployment_id" {
  value = module.api_gateway.deployment_id
}

output "stage_name" {
  value = module.api_gateway.stage_name
}

output "deployment_region" {
  description = "The region where the resources are deployed"
  value       = var.region
}
