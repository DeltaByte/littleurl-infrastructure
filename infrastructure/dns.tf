resource "cloudflare_zone" "default" {
  for_each = var.environments
  zone     = var.domains[each.key]

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_zone_settings_override" "default" {
  for_each = var.environments
  zone_id  = cloudflare_zone.default[each.key].id

  settings {
    ssl                      = "strict"
    tls_1_3                  = "on"
    min_tls_version          = "1.2"
    always_use_https         = "on"
    automatic_https_rewrites = "on"
  }
}

module "dns_webmail" {
  for_each = var.environments
  source   = "./modules/dns-webmail"
  zone_id  = cloudflare_zone.default[each.key].id
}
