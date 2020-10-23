provider "azurerm" {
  features {}
}

resource "azurerm_marketplace_agreement" "copilot" {
  count     = var.mrkt_agreement ? 1 : 0
  publisher = "aviatrix-systems"
  offer     = "aviatrix-copilot"
  plan      = "avx-cplt-byol-01"
}

### Copilot ###
resource "azurerm_network_security_group" "copilot-nsg" {
  name                = "copilot-nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "NetFlow"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "UDP"
    source_port_range          = "*"
    destination_port_range     = "31283"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Syslog"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "UDP"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
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
resource "azurerm_network_interface_security_group_association" "copilot_nsg" {
  network_interface_id      = azurerm_network_interface.avx-copilot-nic.id
  network_security_group_id = azurerm_network_security_group.copilot-nsg.id
}

resource "azurerm_network_interface" "avx-copilot-nic" {
  name                = "avx-copilot-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "avx-copilot-nic"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.avx-copilot-pub.id
  }
}

resource "azurerm_public_ip" "avx-copilot-pub" {
  name                    = "avx-copilot-public-ip"
  location                = var.location
  resource_group_name     = var.rg_name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}
resource "azurerm_virtual_machine" "avxcopilot" {
  name                  = "AviatrixCoPilot"
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = ["${azurerm_network_interface.avx-copilot-nic.id}"]
  vm_size               = "Standard_B8ms"

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "aviatrix-systems"
    offer     = "aviatrix-copilot"
    sku       = "avx-cplt-byol-01"
    version   = "latest"
  }

  plan {
    name      = "avx-cplt-byol-01"
    publisher = "aviatrix-systems"
    product   = "aviatrix-copilot"
  }

  storage_os_disk {
    name              = "avx-copilot-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "avx-copilot"
    admin_username = "avx2020"
    admin_password = var.os_pw
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}