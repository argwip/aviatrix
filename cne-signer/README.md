### Description

This will create a wildcard LetsEncrypt signed application cert for the CNE domain.  The cert will be applied to a number of Controllers and CoPilots for the CNE Workshop

### Variables
The following variables should be applied:

key | value
--- | ---
aws_access_key | AWS Access Key for Route53 DNS challenge
aws_secret_key | AWS Secret Key for Route53 DNS challenge
num_pods | Number of pods that are deployed
offset | Which pod number to start on