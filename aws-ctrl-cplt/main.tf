provider "aws" {
  region = var.region
}
#################
## AWS Shared VPC
#################
resource "aws_vpc" "default" {
  cidr_block           = cidrsubnet(var.cidr, 8, 0)
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "avx-${var.env_name}-vpc" }
}
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = { Name = "avx-${var.env_name}-igw" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  tags = { Name = "avx-${var.env_name}-rt" }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.default.id
  cidr_block = cidrsubnet(var.cidr, 10, 0)
  tags = { Name = "avx-${var.env_name}-subnet" }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
#################
## Controller
#################
data "aws_ami" "ctrl" {
  most_recent = true
  filter {
    name = "name"
    # PAYG:  values = ["*base-ucc-controller-1804-021520-V8*"]
    values = ["*base-ucc-controller-1804-021520-V8-BYOL-109cd06c-210a-4fa4-839b-708683c66dc6-ami-05a1012325610d64b.4*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["679593333241"]
}
resource "aws_eip" "ctrl" {
  vpc = true
}
resource "aws_eip_association" "ctrl" {
  instance_id   = aws_instance.ctrl.id
  allocation_id = aws_eip.ctrl.id
}
resource "aws_security_group" "ctrl" {
  name   = "${var.ctrl_name}-sg"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ctrl" {
  ami                         = data.aws_ami.ctrl.id
  instance_type               = var.ctrl_size
  key_name                    = aws_key_pair.key.key_name
  subnet_id                   = aws_subnet.public.id
  #associate_public_ip_address = true
  security_groups             = [aws_security_group.ctrl.id]
  lifecycle { ignore_changes = [security_groups] }
  tags = { Name = var.ctrl_name }
}
#################
## Co-Pilot
#################
data "aws_ami" "cplt" {
  most_recent = true
  filter {
    name   = "name"
    values = ["*copilot-se-image-100G-V2*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["472991774533"]
}
resource "aws_key_pair" "key" {
  key_name   = "test-key"
  public_key = var.ssh_key
}
resource "aws_eip" "cplt" {
  vpc = true
}
resource "aws_eip_association" "cplt" {
  instance_id   = aws_instance.cplt.id
  allocation_id = aws_eip.cplt.id
}
resource "aws_security_group" "cplt" {
  name   = "${var.cplt_name}-sg"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 31283
    to_port     = 31283
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "cplt" {
  ami                         = data.aws_ami.cplt.id
  instance_type               = var.cplt_size
  key_name                    = aws_key_pair.key.key_name
  subnet_id                   = aws_subnet.public.id
  #associate_public_ip_address = true
  security_groups             = [aws_security_group.cplt.id]
  lifecycle { ignore_changes = [security_groups] }
  tags = { Name = var.cplt_name }
}
#################
## Route 53
#################
data "aws_route53_zone" "pub" {
  count        = var.update_dns ? 1 : 0
  name         = var.dns_zone
  private_zone = false
}
resource "aws_route53_record" "ctrl" {
  count   = var.update_dns ? 1 : 0
  zone_id = data.aws_route53_zone.pub[count.index].zone_id
  name    = "${var.ctrl_hostname}.${data.aws_route53_zone.pub[count.index].name}"
  type    = "A"
  ttl     = "1"
  records = [aws_eip.ctrl.public_ip]
}
resource "aws_route53_record" "cplt" {
  count   = var.update_dns ? 1 : 0
  zone_id = data.aws_route53_zone.pub[count.index].zone_id
  name    = "${var.cplt_hostname}.${data.aws_route53_zone.pub[count.index].name}"
  type    = "A"
  ttl     = "1"
  records = [aws_eip.cplt.public_ip]
}
#################
## Initial Config
#################
resource "null_resource" "controller_initial_config" {
  provisioner "local-exec" {
    command = "python3 ./ctrl.py ${aws_eip.ctrl.public_ip} ${aws_instance.ctrl.private_ip} ${aws_eip.cplt.public_ip} ${var.ctrl_password} ${var.ctrl_version} ${var.ctrl_license} ${var.cplt_license} ${var.email_address}"
  }
  depends_on = [ local_file.ca_cert, local_file.private_key, local_file.certificate ]
  #depends_on = [ local_file.ca_ctrl, local_file.priv_ctrl, local_file.cert_ctrl, local_file.ca_cplt, local_file.priv_cplt, local_file.cert_cplt ]
}