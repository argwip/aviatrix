### Description

This will deploy Aviatrix Controller in AWS

### Variables
The following variables are required:

key | description
--- | ---
aws_access_key | 
aws_secret_key | 
subnet_id | AWS Subnet ID to launch the EC2 instance in
vpc_id | AWS VPC ID to launch the EC2 instance in

The following variables are optional:

key | value | description
--- | --- | ---
region | eu-central-1 | AWS Region to deploy AVX Controller
instance_size | t2.large | EC2 instance size
instance_name | aviatrix-controller | EC2 instance name