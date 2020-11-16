### Description

This will deploy Aviatrix CoPilot in AWS

### Variables
The following variables are required:

key | value
--- | ---
subnet_id | AWS Subnet ID to launch the EC2 instance in
vpc_id | AWS VPC ID to launch the EC2 instance in

The following variables are optional:

key | value | description
--- | --- | ---
region | eu-central-1 | AWS Region to deploy AVX Controller
instance_size | m5.2xlarge | EC2 instance size
instance_name | aviatrix-controller | EC2 instance name