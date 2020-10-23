provider "azurerm" {
  features {}
}

resource "azurerm_marketplace_agreement" "controller" {
  count     = var.mrkt_agreement ? 1 : 0
  publisher = "aviatrix-systems"
  offer     = "aviatrix-bundle-payg"
  plan      = "aviatrix-enterprise-bundle-byol"
}

### Controller ###
resource "azurerm_network_interface" "main" {
  name                = "avx-ctrl-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "avx-ctrl-nic"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_public_ip" "main" {
  name                    = "avx-ctrl-public-ip"
  location                = var.location
  resource_group_name     = var.rg_name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_security_group" "ctrl-nsg" {
  name                = "ctrl-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "ctrl_nsg" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.ctrl-nsg.id
}

resource "azurerm_virtual_machine" "avxctrl" {
  name                  = var.instance_name
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = var.instance_size

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "aviatrix-systems"
    offer     = "aviatrix-bundle-payg"
    sku       = "aviatrix-enterprise-bundle-byol"
    version   = "latest"
  }

  plan {
    name      = "aviatrix-enterprise-bundle-byol"
    publisher = "aviatrix-systems"
    product   = "aviatrix-bundle-payg"
  }

  storage_os_disk {
    name              = "avxdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "avx-controller"
    admin_username = "avx2020"
    admin_password = var.os_pw
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
