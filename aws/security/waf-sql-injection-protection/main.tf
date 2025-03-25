module "lambda" {
  source        = "./modules/lambda-function"
  function_name = "sql-injection-vulnerable"
}

module "api_gateway" {
  source               = "./modules/api-gateway"
  api_name             = "vulnerable-api"
  stage_name           = "stage"
  lambda_resource_path = "sql-injection"
  lambda_invoke_arn    = module.lambda.lambda_function_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
  accountId            = var.accountId
  region               = var.region
}

module "waf" {
  source        = "./modules/waf"
  api_stage_arn = module.api_gateway.stage_arn
}