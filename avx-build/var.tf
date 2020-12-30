variable "location" { default = "North Europe" }
variable "instance_name" { default = "aviatrix-controller" }
variable "name" { default = "avx-build" }
variable "ssh_key" { default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw/B8Q8KJChmY2bdUx5rrGt/B1p203cF+IDU0oAy7UoZZzsKSUMOqn5UoFBcOlU6zJpMTboyLz/0cs9NPjhhyzJTJh6tt9eSh6Bigbf3BY7MOsPjizsaTWGbLyHxinqE5aYHMtPeaesBt3anJLhBO0diFu0YgoxYvSYGtqf2PQl8uRo1pcjkFbb41hZF49tmNLEy6rVQKwcD3IeUM/mfLGuYWpJ/01Sm/LeRYkNGRPgw4X0QL4xxQxc4z3HrwBlDqaqfPgzc1p9/w4wiXm+ZqXajwoDL30DXewKEaz6hnt1vg/fmLix4V++W26dZhWOSw3ujA81E+lAGXdUsY13sdD frey@Freys-Air.fritz.box" }

variable "instance_size" { default = "Standard_B2ms" }
variable "rg_name" { default = "privlink-rg" }
variable "subnet_id" { default = "/subscriptions/cd0efb1b-7b12-46e5-b53a-c394d8f9b923/resourceGroups/privlink-rg/providers/Microsoft.Network/virtualNetworks/privlink-rg-vnet/subnets/default" }
variable "username" { default = "avx" }
variable "password" { default = "Aviatrix12345-" }
variable "dns_zone" { default = "avxlab.de" }
variable "dns_hostname" { default = "lab" }
variable "aws_region" { default = "eu-central-1" }
variable "pod_id" { default = "22" }
