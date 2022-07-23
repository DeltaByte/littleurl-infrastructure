terraform {
  backend "s3" {
    bucket               = "littleurl-terraform-state"
    key                  = "state/infrastrucutre.tfstate"
    region               = "us-east-1"
    encrypt              = true
    dynamodb_table       = "littleurl-terraform-lock"
    # workspace_key_prefix = "state"
    # assume_role_tags = {
    #   service     = "infrastrucutre"
    #   environment = terraform.workspace
    # }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.19"
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Misc Providers
# ----------------------------------------------------------------------------------------------------------------------
provider "cloudflare" {}

# ----------------------------------------------------------------------------------------------------------------------
# AWS Provider
# ----------------------------------------------------------------------------------------------------------------------
# ROOT aws account, should only be chosen carefully as resources will exist outside of littleurl accounts
provider "aws" {
  region = var.aws_region

  default_tags { tags = var.aws_default_tags }
}

provider "aws" {
  alias  = "prod"
  region = var.aws_region

  allowed_account_ids = [aws_organizations_account.prod.id]
  default_tags { tags = var.aws_default_tags }

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.prod.id}:role/${local.aws_org_role}"
    session_name = "terraform-${var.project_name}-infrastructure"
  }
}

provider "aws" {
  alias  = "dev"
  region = var.aws_region

  allowed_account_ids = [aws_organizations_account.dev.id]
  default_tags { tags = var.aws_default_tags }

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.dev.id}:role/${local.aws_org_role}"
    session_name = "terraform-${var.project_name}-infrastructure"
  }
}
