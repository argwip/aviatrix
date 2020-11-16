### Description

This will deploy a shared VPC, Aviatrix Controller and Aviatrix CoPilot in AWS

### Variables
The following variables are required:

key | value
--- | ---
ctrl_license | License for the AVX Controller
cplt_license | License for AVX CoPilot

The following variables are optional:

key | value | description
--- | --- | ---
env_name | shared | Name for the VPC, Subnet, etc
cidr | 10.20.0.0/16 | CIDR range for VPC, Subnet
region | eu-central-1 | AWS Region 
ctrl_name | avx-controller | Controller EC2 instance name
cplt_name | avx-copilot | CoPilot EC2 instance name
ctrl_size | t2.large | Controller EC2 instance size
cplt_size | t3.medium | CoPilot EC2 instance size
ctrl_password | Password123 | Password for the Controller and CoPilot
update_dns | true | Update a Route53 DNS Zone. Set to false to disable DNS update
dns_zone | avxlab.de | DNS zone to update
ctrl_hostname | ctrl | Hostname for the Controller
cplt_hostname | cplt | Hostname for CoPilot