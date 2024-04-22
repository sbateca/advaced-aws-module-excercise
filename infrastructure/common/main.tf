module lambda {
  source = "./lambda"
  environment_name = var.environment_name
  lambda_role_arn = module.iam.lambda_role_arn
  region = var.region
}

module gateway {
  source = "./gateway"
  environment_name = var.environment_name
  invoke_arn = module.lambda.lambda_invoke_arn
} 

module s3 {
  source = "./s3"
  environment_name = var.environment_name
}

module "iam" {
  source = "./iam"
  region = var.region
}