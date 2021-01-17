variable "dns_aws_access_key" { }
variable "dns_aws_secret_key" { }
variable "aws_region" { default = "eu-central-1" }
variable "dns_zone" { default = "fk.avxlab.de" }
variable "email_address" { default = "frey@aviatrix.com" }
variable "offset" { default = 1 }
variable "num_pods" { default = 10 }
variable "bucket_name" { default = "avx-build" }