resource "cloudflare_record" "webmail_mx10" {
  zone_id  = var.zone_id
  name     = "@"
  type     = "MX"
  value    = "spool.mail.gandi.net"
  ttl      = 10800
  priority = 10
}

resource "cloudflare_record" "webmail_mx50" {
  zone_id  = var.zone_id
  name     = "@"
  type     = "MX"
  value    = "fb.mail.gandi.net"
  ttl      = 10800
  priority = 50
}

resource "cloudflare_record" "webmail_spf" {
  zone_id = var.zone_id
  name    = "@"
  type    = "TXT"
  value   = "v=spf1 include:_mailcust.gandi.net include:amazonses.com ~all"
  ttl     = 10800
}