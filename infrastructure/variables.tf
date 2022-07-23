# ----------------------------------------------------------------------------------------------------------------------
# Misc
# ----------------------------------------------------------------------------------------------------------------------
variable "application" {
  type    = string
  default = "littleurl"
}

variable "environments" {
  type    = set(string)
  default = ["dev", "prod"]
}

variable "domains" {
  type = map(string)
  default = {
    dev  = "littleurl.dev"
    prod = "littleurl.io"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# AWS
# ----------------------------------------------------------------------------------------------------------------------
locals {
  aws_org_role = "OrganizationAccountAccessRole"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_root_org" {
  type        = string
  description = "Root AWS organisation ID"
  sensitive   = true
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Common resource tags for all AWS resources"
  default = {
    service = "infrastructure"
  }
}
