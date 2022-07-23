terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Deployment
# ----------------------------------------------------------------------------------------------------------------------
module "deployment" {
  source = "../modules/deployment-entity"

  name             = "api"
  remotestate_role = var.backend_role_arn
}

# ----------------------------------------------------------------------------------------------------------------------
# Permissions: Built-in
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ses" {
  role       = module.deployment.role_id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

// TODO: remove this bollocks
resource "aws_iam_role_policy_attachment" "admin" {
  role       = module.deployment.role_id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
