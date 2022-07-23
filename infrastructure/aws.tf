locals {
  aws_account_ids = {
    prod = aws_organizations_account.prod.id
    dev  = aws_organizations_account.dev.id
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Accounts
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_organizations_organizational_unit" "default" {
  name      = var.application
  parent_id = var.aws_root_org
}

resource "aws_organizations_account" "prod" {
  name      = "${var.application}-prod"
  email     = "aws@${var.domains["prod"]}"
  parent_id = aws_organizations_organizational_unit.default.id
  role_name = local.aws_org_role
}

resource "aws_organizations_account" "dev" {
  name      = "${var.application}-dev"
  email     = "aws@${var.domains["dev"]}"
  parent_id = aws_organizations_organizational_unit.default.id
  role_name = local.aws_org_role
}
