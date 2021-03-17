#variable "aws_access_key" {}
#variable "aws_secret_key" {}
variable "env_name" { default = "test" }
variable "cidr" { default = "10.250.0.0/16" }
variable "region" { default = "eu-central-1" }
variable "ctrl_name" { default = "avx-controller" }
variable "cplt_name" { default = "avx-copilot" }
variable "ctrl_size" { default = "t2.large" }
variable "cplt_size" { default = "t3.medium" }
variable "ctrl_version" { default = "6.3" }
variable "ctrl_license" { }
variable "cplt_license" { }
variable "ctrl_password" { }
variable "email_address" { default = "frey@aviatrix.com" }
# DNS
variable "update_dns" {
  type    = bool
  default = true
}
variable "dns_zone" { default = "avxlab.de" }
variable "ctrl_hostname" { default = "ctrl" }
variable "cplt_hostname" { default = "cplt" }
# SSL
variable "access_key_dns" { }
variable "secret_key_dns" { }
variable "ssh_key" { }