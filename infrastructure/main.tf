module lambda {
  source = "./common/lambda"
  environment_name = local.environment_name
  lambda_role_arn = module.iam.lambda_role_arn
}

module gateway {
  source = "./common/gateway"
  environment_name = local.environment_name
  invoke_arn = module.lambda.lambda_invoke_arn
} 

module s3 {
  source = "./common/s3"
  environment_name = local.environment_name
}

module "iam" {
  source = "./common/iam"
  region = local.region
}