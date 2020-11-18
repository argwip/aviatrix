provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
## Wildcard Cert ##
resource "tls_private_key" "ctrl" {
  algorithm = "RSA"
}
resource "acme_registration" "ctrl" {
  account_key_pem = tls_private_key.ctrl.private_key_pem
  email_address   = var.email_address
}
resource "acme_certificate" "ctrl" {
  account_key_pem           = acme_registration.ctrl.account_key_pem
  common_name               = "*.${var.dns_zone}"

  dns_challenge {
    provider = "route53"

      config = {
      AWS_ACCESS_KEY_ID     = var.aws_access_key
      AWS_SECRET_ACCESS_KEY = var.aws_secret_key
      AWS_DEFAULT_REGION    = var.region
    }  
  }
}
resource "local_file" "ca" {
  sensitive_content = acme_certificate.ctrl.issuer_pem
  filename          = "${path.module}/ca.pem"
}
resource "local_file" "priv" {
  sensitive_content = acme_certificate.ctrl.private_key_pem
  filename          = "${path.module}/priv.pem"
}
resource "local_file" "cert" {
  sensitive_content = acme_certificate.ctrl.certificate_pem
  filename          = "${path.module}/cert.pem"
}
resource "null_resource" "controller_initial_config" {
  count = var.num_pods

  provisioner "local-exec" {
    # Input:  <ctrl-fqdn> <cplt-fqdn> <ctrl-password> <cplt-username> <cplt-password>
    command = "python3 ./cert.py ctrl-pod${count.index + var.offset}.pub.avxlab.nl copilot-pod${count.index + var.offset}.pub.avxlab.nl ${var.ctrl_password} ${var.cplt_user} ${var.cplt_password}"
  }
  depends_on = [ local_file.ca, local_file.priv, local_file.cert ]
}