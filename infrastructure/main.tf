# ----------------------------------------------------------------------------------------------------------------------
# API
# ----------------------------------------------------------------------------------------------------------------------
module "deploy_api_dev" {
  source           = "./iam-api"
  backend_role_arn = aws_iam_role.remotestate["dev"].arn

  providers = {
    aws = aws.dev
  }
}

module "deploy_api_prod" {
  source           = "./iam-api"
  backend_role_arn = aws_iam_role.remotestate["prod"].arn

  providers = {
    aws = aws.prod
  }
}
