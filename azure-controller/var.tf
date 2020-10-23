variable "location" { default = "Germany West Central" }
variable "instance_name" { default = "aviatrix-controller" }
variable "os_pw" { default = "Password1234" }
variable "mrkt_agreement" {
    type = boolean
    description = "Type true to accept the license terms and false to ignore (already accepted)" 
}
variable "instance_size" { default = "Standard_B2ms" }
variable "rg_name" { }
variable "subnet_id" { }