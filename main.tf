# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "IaaS_RG" {
  name     = "${var.env_name}-RG"
  location = var.resource_group_location
}

# Create network security group
resource "azurerm_network_security_group" "IaaS_SG" {
  name                = "${var.env_name}-SG"
  location            = azurerm_resource_group.IaaS_RG.location
  resource_group_name = azurerm_resource_group.IaaS_RG.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "23"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "IaaS_Net" {
  name                = "${var.env_name}-network"
  resource_group_name = azurerm_resource_group.IaaS_RG.name
  location            = azurerm_resource_group.IaaS_RG.location
  address_space       = ["${var.network_address_pefix}0.0/16"]
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "IaaS_SubNet1" {
  name                 = "${var.env_name}-sn1"
  resource_group_name  = azurerm_resource_group.IaaS_RG.name
  virtual_network_name = azurerm_virtual_network.IaaS_Net.name
  address_prefix       = "${var.network_address_pefix}1.0/24"
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "IaaS_SubNet2" {
  name                 = "${var.env_name}-sn2"
  resource_group_name  = azurerm_resource_group.IaaS_RG.name
  virtual_network_name = azurerm_virtual_network.IaaS_Net.name
  address_prefix       = "${var.network_address_pefix}2.0/24"
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "IaaS_SubNet3" {
  name                 = "${var.env_name}-sn3"
  resource_group_name  = azurerm_resource_group.IaaS_RG.name
  virtual_network_name = azurerm_virtual_network.IaaS_Net.name
  address_prefix       = "${var.network_address_pefix}3.0/24"
  # security_group = azurerm_network_security_group.IaaS_SG.id
}

# Reserve Public IP
resource "azurerm_public_ip" "IaaS_PublicIP" {
  name                = "${var.env_name}-IP1"
  location            = azurerm_resource_group.IaaS_RG.location
  resource_group_name = azurerm_resource_group.IaaS_RG.name
  allocation_method   = "Dynamic"
}

# Create a NIC
resource "azurerm_network_interface" "IaaS_Net-Interface" {
  name                = "${var.env_name}-nic"
  location            = azurerm_resource_group.IaaS_RG.location
  resource_group_name = azurerm_resource_group.IaaS_RG.name

  ip_configuration {
    name                          = "${var.env_name}-nic_config"
    subnet_id                     = azurerm_subnet.IaaS_SubNet3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.IaaS_PublicIP.id
  }
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

# Create a Virtual Machine
resource "azurerm_virtual_machine" "IaaS_VM1" {
  name                  = "${var.env_name}-vm1"
  location              = azurerm_resource_group.IaaS_RG.location
  resource_group_name   = azurerm_resource_group.IaaS_RG.name
  network_interface_ids = ["${azurerm_network_interface.IaaS_Net-Interface.id}"]
  vm_size               = "Standard_B1ms"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.env_name}-myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.env_name}-Server1"
    admin_username = "vmadmin"
    admin_password = random_password.password.result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
