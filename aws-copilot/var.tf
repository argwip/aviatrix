# AWS
variable "subnet_id" {}
variable "vpc_id" {}
variable "region" { default = "eu-central-1" }
variable "instance_size" { default = "t2.medium" }
variable "instance_name" { default = "aviatrix-copilot" }