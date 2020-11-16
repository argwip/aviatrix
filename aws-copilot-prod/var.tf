# AWS
variable "subnet_id" {}
variable "vpc_id" {}
variable "region" { default = "eu-central-1" }
variable "instance_size" { default = "m5.2xlarge" }
variable "instance_name" { default = "aviatrix-copilot" }