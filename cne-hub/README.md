### Description
This code will build a transit VPC with an Aviatrix Transit Gateway, a spoke VPC with an Aviatrix Spoke GW and peer them together.  Additionally "n" Site2Cloud connections will be created on the Transit GW to simulate a pseudo DC for the CNE.

### Diagram
<img src="https://github.com/fkhademi/cne-hub/blob/master/diagram.png?raw=true" height="450">

### Variables
The following variables are required:

key | value
:--- | :---
aviatrix_admin_password | Aviatrix admin password
aviatrix_controller_ip | Aviatrix Controller IP/Hostname
num_pods | Number of pods that will be created in the CNE
ssh_key | Ubuntu client SSH key
aws_access_key | AWS access key for creating compute
aws_secret_key | AWS secret key for creating compute
aws_access_key_dns | AWS access key for updating Route53
aws_secret_key_dns | AWS secret key for updating Route53

The following variables are optional:

key | default | value 
:---|:---|:---
aws_account_name | aws-fk | AWS account name define in the AVX Controller
domain_name | pub.avxlab.nl | Route53 domain name
priv_domain_name | priv.avxlab.nl | Route53 domain name for RFC1918 hosts
hub_cidr | 172.16.0.0/16 | CIDR range to be used for pseudo DC
hub_region | eu-central-1 | Region to deploy the pseudo DC
offset  | 1 | Start offset for counting the Pods