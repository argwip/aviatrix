# Module deploy Transit
module "transit_hub" {
  #source    = "terraform-aviatrix-modules/aws-transit/aviatrix"
  #version   = "v1.1.0"
  source                           = "git::https://github.com/fkhademi/terraform-aviatrix-aws-transit.git"
  cidr                             = cidrsubnet(var.hub_cidr, 4, 0)
  region                           = var.hub_region
  account                          = var.aws_account_name
  bgp_manual_spoke_advertise_cidrs = "0.0.0.0/0,${var.hub_cidr}"
  ha_gw                            = false
}

# Module deploy Spoke
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "1.1.0"

  cidr       = cidrsubnet(var.hub_cidr, 4, 1)
  name       = "pseudo-dc"
  region     = var.hub_region
  account    = var.aws_account_name
  transit_gw = module.transit_hub.transit_gateway.gw_name
  ha_gw      = false
}

# Module deploy AWS EC2
module "aws_srv1" {
  source = "git::https://github.com/fkhademi/terraform-aws-instance-module.git"

  name      = "cne-hub-client"
  region    = var.hub_region
  vpc_id    = module.spoke_aws_1.vpc.vpc_id
  subnet_id = module.spoke_aws_1.vpc.subnets[0].subnet_id
  ssh_key   = var.ssh_key
}
resource "aws_route53_record" "srv-priv" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.priv_domain_name.zone_id
  name     = "onprem.${data.aws_route53_zone.priv_domain_name.name}"
  type     = "A"
  ttl      = "1"
  records  = [module.aws_srv1.vm.private_ip]
}
resource "aws_route53_record" "trans_gw" {
  provider = aws.dns
  zone_id  = data.aws_route53_zone.domain_name.zone_id
  name     = "onprem-gw.${data.aws_route53_zone.domain_name.name}"
  type     = "A"
  ttl      = "1"
  records  = [module.transit_hub.transit_gateway.eip]
}

#Transit workflow step 3
resource "aviatrix_transit_external_device_conn" "s2c" {
  count = var.num_pods

  vpc_id             = module.transit_hub.vpc.vpc_id
  connection_name    = "pod${count.index + var.offset}"
  gw_name            = module.transit_hub.transit_gateway.gw_name
  connection_type    = "bgp"
  bgp_local_as_num   = "65000"
  bgp_remote_as_num  = "650${format("%02d", count.index + var.offset)}"
  remote_gateway_ip  = data.dns_a_record_set.fqdn[count.index].addrs[0]
  pre_shared_key     = "mapleleafs"
  local_tunnel_cidr  = "169.254.${count.index + var.offset}.1/30"
  remote_tunnel_cidr = "169.254.${count.index + var.offset}.2/30"
}