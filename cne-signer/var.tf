#Aviatrix controller vars
variable "ctrl_user" {
  description = "Aviatrix admin user"
  default     = "admin"
}
variable "ctrl_password" {
  default = "Password123"
}
variable "cplt_user" {
  default     = "copilot"
}
variable "cplt_password" {
  default = "Copilot123!"
}

# AWS account for Route53 
variable "aws_access_key" {
  description = "AWS Access Key"
}
variable "aws_secret_key" {
  description = "AWS Secret Key"
}
variable "region" {
  description = "AWS region to deploy resources"
  default     = "eu-central-1"
}

# CNE details
variable "num_pods" {
  description = "Number of Pods deployed"
  default     = 20
}
variable "offset" {
  description = "Pod number to start on"
  default     = 1
}
variable "dns_zone" {
  description = "Public Route53 Domain to update"
  default     = "pub.avxlab.nl"
}
variable "email_address" {
  description = "Email address for the cert"
  default     = "cne@aviatrix.com"
}