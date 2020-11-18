provider "aviatrix" {
  controller_ip           = var.aviatrix_controller_ip
  username                = var.aviatrix_admin_account
  password                = var.aviatrix_admin_password
  skip_version_validation = false
  version                 = ">=2.16.0"
}
provider "aws" {
  region     = var.hub_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "dns" {
  update {
    server = "8.8.8.8"
  }
}
provider "aws" {
  alias      = "dns"
  region     = var.hub_region
  access_key = var.aws_access_key_dns
  secret_key = var.aws_secret_key_dns
}