variable "location" { default = "North Europe" }
variable "instance_name" { default = "aviatrix-controller" }
variable "name" { default = "avx-build" }
variable "ssh_key" { }
variable "instance_size" { default = "Standard_B2ms" }
variable "rg_name" { default = "privlink-rg" }
variable "subnet_id" { default = "/subscriptions/cd0efb1b-7b12-46e5-b53a-c394d8f9b923/resourceGroups/privlink-rg/providers/Microsoft.Network/virtualNetworks/privlink-rg-vnet/subnets/default" }
variable "username" { default = "cne" }
variable "password" { }
variable "dns_zone" { default = "avxlab.de" }
variable "dns_hostname" { default = "lab" }
variable "aws_region" { default = "eu-central-1" }
