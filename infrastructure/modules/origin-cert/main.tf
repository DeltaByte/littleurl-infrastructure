resource "aws_ssm_parameter" "api_origin_cert" {
  name  = var.ssm_name
  type  = "String"
  value = aws_acm_certificate.cloudflare_origin.arn
}

# ----------------------------------------------------------------------------------------------------------------------
# Generated Cert
# ----------------------------------------------------------------------------------------------------------------------
resource "tls_private_key" "cloudflare_origin" {
  algorithm = "RSA"
}

resource "tls_cert_request" "cloudflare_origin" {
  private_key_pem = tls_private_key.cloudflare_origin.private_key_pem

  dns_names = var.domains

  dynamic "subject" {
    for_each = var.domains

    content {
      common_name  = subject.key
      organization = var.organization
    }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Cloudflare CA
# ----------------------------------------------------------------------------------------------------------------------
resource "cloudflare_origin_ca_certificate" "acm" {
  csr                = tls_cert_request.cloudflare_origin.cert_request_pem
  hostnames          = var.domains
  request_type       = "origin-rsa"
  requested_validity = 5475 // (15yrs) Cloudflare default
}

# ----------------------------------------------------------------------------------------------------------------------
# AWS CertManager
# ----------------------------------------------------------------------------------------------------------------------
data "http" "cloudflare_origin_root_ca" {
  url = "https://developers.cloudflare.com/ssl/static/origin_ca_rsa_root.pem"
}

resource "aws_acm_certificate" "cloudflare_origin" {
  private_key       = tls_private_key.cloudflare_origin.private_key_pem
  certificate_body  = cloudflare_origin_ca_certificate.acm.certificate
  certificate_chain = data.http.cloudflare_origin_root_ca.response_body
}
