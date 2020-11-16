provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "sg" {
  name   = "${var.instance_name}-sg"
  vpc_id = var.vpc_id

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

resource "aws_eip" "ctrl" {
  vpc = true
}

resource "aws_eip_association" "ctrl" {
  instance_id   = aws_instance.ctrl.id
  allocation_id = aws_eip.ctrl.id
}

resource "aws_instance" "ctrl" {
  ami                         = "ami-0ef23847d2716838e"
  instance_type               = var.instance_size
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.sg.id]
  lifecycle {
    ignore_changes = [security_groups]
  }
  tags = {
    Name = var.instance_name
  }
}