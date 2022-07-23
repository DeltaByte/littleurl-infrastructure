resource "cloudflare_zone" "default" {
  zone = var.domain

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_zone_settings_override" "default" {
  zone_id = cloudflare_zone.default.id

  settings {
    ssl                      = "strict"
    tls_1_3                  = "on"
    min_tls_version          = "1.2"
    always_use_https         = "on"
    automatic_https_rewrites = "on"
  }
}
