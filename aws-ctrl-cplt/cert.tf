provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "frey@aviatrix.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "*.avxlab.de"

  dns_challenge {
    provider = "route53"

      config = {
      AWS_ACCESS_KEY_ID     = var.access_key_dns
      AWS_SECRET_ACCESS_KEY = var.secret_key_dns
      AWS_DEFAULT_REGION    = "eu-central-1"
    }  
  }
}
resource "local_file" "ca_cert" {
  sensitive_content = acme_certificate.certificate.issuer_pem
  filename          = "${path.module}/ca_cert.pem"
}

resource "local_file" "private_key" {
  sensitive_content = acme_certificate.certificate.private_key_pem
  filename          = "${path.module}/private_key.pem"
}

resource "local_file" "certificate" {
  sensitive_content = acme_certificate.certificate.certificate_pem
  filename          = "${path.module}/certificate.pem"
}