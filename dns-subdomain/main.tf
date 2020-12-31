provider "aws" {
  version    = "~> 2.0"
  region     = var.aws_region
  access_key = var.dns_aws_access_key
  secret_key = var.dns_aws_secret_key
}
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "aws_route53_zone" "subzone" {
name          = "pod${var.pod_id}.${var.dns_zone}"
force_destroy = false
}
data "aws_route53_zone" "parentzone" {
  name         = var.dns_zone
  private_zone = false
}

data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_route53_record" "delegation" {
  allow_overwrite = true
  name            = aws_route53_zone.subzone.name
  ttl             = 1
  type            = "NS"
  zone_id         = data.aws_route53_zone.parentzone.zone_id

  records = [
    aws_route53_zone.subzone.name_servers[0],
    aws_route53_zone.subzone.name_servers[1],
    aws_route53_zone.subzone.name_servers[2],
    aws_route53_zone.subzone.name_servers[3],
  ]
}

## Wildcard Cert ##
resource "tls_private_key" "ctrl" {
  algorithm = "RSA"
  depends_on = [
    aws_route53_zone.subzone, aws_route53_record.delegation
  ]
}
resource "acme_registration" "ctrl" {
  account_key_pem = tls_private_key.ctrl.private_key_pem
  email_address   = var.email_address
  depends_on = [
    aws_route53_zone.subzone, aws_route53_record.delegation
  ]
}
resource "acme_certificate" "ctrl" {
  account_key_pem = acme_registration.ctrl.account_key_pem
  common_name     = "*.pod${var.pod_id}.${var.dns_zone}"

  dns_challenge {
    provider = "route53"

    config = {
      AWS_ACCESS_KEY_ID     = var.dns_aws_access_key
      AWS_SECRET_ACCESS_KEY = var.dns_aws_secret_key
      AWS_DEFAULT_REGION    = var.aws_region
    }
  }
  depends_on = [
    aws_route53_zone.subzone, aws_route53_record.delegation
  ]
}
resource "local_file" "ca" {
  sensitive_content = acme_certificate.ctrl.issuer_pem
  filename          = "${path.module}/ca.pem"
}
resource "local_file" "priv" {
  sensitive_content = acme_certificate.ctrl.private_key_pem
  filename          = "${path.module}/cert.key"
}
resource "local_file" "cert" {
  sensitive_content = acme_certificate.ctrl.certificate_pem
  filename          = "${path.module}/cert.crt"
}

resource "aws_s3_bucket_object" "cert" {
  bucket = data.aws_s3_bucket.bucket.id
  key    = "pod${var.pod_id}-cert.crt"
  acl    = "public-read"
  source = "${path.module}/cert.crt"
  depends_on = [
    local_file.priv, local_file.cert
  ]
}
resource "aws_s3_bucket_object" "key" {
  bucket = data.aws_s3_bucket.bucket.id
  key    = "pod${var.pod_id}-cert.key"
  acl    = "public-read"
  source = "${path.module}/cert.key"
  depends_on = [
    local_file.priv, local_file.cert
  ]
}