module lambda {
  source = "./lambda"
  environment_name = var.environment_name
}

module gateway {
  source = "./gateway"
  environment_name = var.environment_name
} 

module s3 {
  source = "./s3"
  environment_name = var.environment_name
}

module "iam" {
  source = "./iam"
  region = var.region
}