data "dns_a_record_set" "fqdn" {
  count = var.num_pods

  host = "pod${count.index + var.offset}-tgw.${var.domain_name}"
}
data "aws_route53_zone" "domain_name" {
  provider     = aws.dns
  name         = var.domain_name
  private_zone = false
}
data "aws_route53_zone" "priv_domain_name" {
  provider     = aws.dns
  name         = var.priv_domain_name
  private_zone = false
}