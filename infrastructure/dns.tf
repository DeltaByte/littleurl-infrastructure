module "dns_zone" {
  for_each = var.environments
  source   = "./modules/dns-zone"

  application = var.application
  domain      = var.domains[each.key]
}

resource "aws_ssm_parameter" "cloudflare_zone_dev" {
  provider = aws.dev

  name  = "/${var.application}/cloudflare-zone"
  type  = "String"
  value = module.dns_zone["dev"].zone_id
}

resource "aws_ssm_parameter" "cloudflare_zone_prod" {
  provider = aws.prod

  name  = "/${var.application}/cloudflare-zone"
  type  = "String"
  value = module.dns_zone["prod"].zone_id
}
