# ----------------------------------------------------------------------------------------------------------------------
# Dev
# ----------------------------------------------------------------------------------------------------------------------
module "deploy_api_dev" {
  source           = "./iam-api"
  backend_role_arn = aws_iam_role.remotestate["dev"].arn

  providers = {
    aws = aws.dev
  }
}

module "origin_cert_api_dev" {
  source = "./modules/origin-cert"

  ssm_name     = "/${var.application}/api-certificate-arn"
  organization = "${var.application} (Terraform)"
  domains      = ["api.${var.domains["dev"]}"]

  providers = {
    aws = aws.dev
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Prod
# ----------------------------------------------------------------------------------------------------------------------
module "deploy_api_prod" {
  source           = "./iam-api"
  backend_role_arn = aws_iam_role.remotestate["prod"].arn

  providers = {
    aws = aws.prod
  }
}


module "origin_cert_api_prod" {
  source = "./modules/origin-cert"

  ssm_name     = "/${var.application}/api-certificate-arn"
  organization = "${var.application} (Terraform)"
  domains      = ["api.${var.domains["prod"]}"]

  providers = {
    aws = aws.prod
  }
}
