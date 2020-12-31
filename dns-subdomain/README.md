# dns-subdomain

### Description

This will create the following:

* A DNS subdomain in Route53
* The necessary glue and authority records in the parent domain
* A wildcard cert signed by LetsEncrypt for this subdomain
* The cert and key will be stored in an S3 bucket

### Variables
The following variables are required:

key | value
--- | ---
dns_aws_access_key | Access Key with permissions to R53 and S3
dns_aws_secret_key | Secret Key with permissions to R53 and S3
pod_id | A number between 0 and 255

The following variables are optional:

key | default value
--- | ---
aws_region | eu-central-1
dns_zone | avxlab.de
email_address | frey@aviatrix.com
bucket_name | avx-build