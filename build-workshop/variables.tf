#Aviatrix controller vars
variable "aviatrix_admin_account" { default = "admin" }
variable "aviatrix_admin_password" { }
variable "aviatrix_controller_ip" { }

#Regions
variable "aws_region" { default = "eu-central-1" }
variable "azure_region" { default = "Germany West Central" }

#Contoller access accounts
variable "aws_account_name" { default = "AWS" }
variable "azure_account_name" { default = "Azure" }

#CSP Accounts
variable "aws_account_number" {
  type    = string
}
variable "aws_access_key" {
  type    = string
}
variable "aws_secret_key" {
  type    = string
}
variable "azure_subscription_id" { }
variable "azure_directory_id" { }
variable "azure_application_id" { }
variable "azure_application_key" { }

# Client Details
variable "ssh_key" {
  type    = string
}
variable "username" {
  default = "avx"
}
variable "password" {
}
variable "pod_id" {
  default = 22
  type    = string
}

variable "dns_zone" {
  type    = string
  default = "avxlab.de"
}

#AWS Account used for route53 DNS
variable "dns_aws_access_key" { }
variable "dns_aws_secret_key" { }
