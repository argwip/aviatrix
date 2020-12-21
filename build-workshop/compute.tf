data "azurerm_subnet" "client" {
  name                 = module.azure_spoke_1.vnet.subnets[0].name
  virtual_network_name = module.azure_spoke_1.vnet.name
  resource_group_name  = split(":", module.azure_spoke_1.vnet.vpc_id)[1]
}

resource "azurerm_network_interface" "client" {
  name                = "client-pod${var.pod_id}"
  location            = var.azure_region
  resource_group_name = split(":", module.azure_spoke_1.vnet.vpc_id)[1]

  ip_configuration {
    name                          = "client-pod${var.pod_id}"
    subnet_id                     = data.azurerm_subnet.client.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.client.id
  }
}

resource "azurerm_public_ip" "client" {
  name                    = "client-pod${var.pod_id}"
  location                = var.azure_region
  resource_group_name     = split(":", module.azure_spoke_1.vnet.vpc_id)[1]
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_security_group" "client" {
  name                = "client-pod${var.pod_id}"
  location            = var.azure_region
  resource_group_name = split(":", module.azure_spoke_1.vnet.vpc_id)[1]

  security_rule {
    name                       = "HTTPS"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "client" {
  network_interface_id      = azurerm_network_interface.client.id
  network_security_group_id = azurerm_network_security_group.client.id
}

resource "azurerm_virtual_machine" "client" {
  name                  = "client-pod${var.pod_id}"
  location              = var.azure_region
  resource_group_name   = split(":", module.azure_spoke_1.vnet.vpc_id)[1]
  network_interface_ids = ["${azurerm_network_interface.client.id}"]
  vm_size               = "Standard_B2ms"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "client-pod${var.pod_id}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "client-pod${var.pod_id}"
    admin_username = "ubuntu"
    custom_data    = data.template_cloudinit_config.config.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = var.ssh_key
    }
  }
}

data "template_file" "cloudconfig" {
  template = file("${path.module}/cloud-init.tpl")
  vars = {
    username = "${var.username}"
    password = "${var.password}"
    hostname = "client.pod${var.pod_id}.${var.dns_zone}"
    pod_id   = "pod${var.pod_id}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}

data "aws_route53_zone" "main" {
  name         = "pod${var.pod_id}.${var.dns_zone}"
  private_zone = false
}

resource "aws_route53_record" "client" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "client.${data.aws_route53_zone.main.name}"
  type    = "A"
  ttl     = "1"
  records = [azurerm_public_ip.client.ip_address]
}