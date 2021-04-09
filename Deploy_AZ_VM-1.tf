resource "azurerm_resource_group" "Red-net" {
    name        ="Cameron Todd"
    location    ="WestUS"

    tags {
        owner   ="Cameron Todd"
    }
}

variable "prefix" {
  default = "Web-3"
}


resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Red-net.location
  resource_group_name = azurerm_resource_group.Red-net.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Red-net.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.Red-net.location
  resource_group_name = azurerm_resource_group.Red-net.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.Red-net.location
  resource_group_name   = azurerm_resource_group.Red-net.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s_v1"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "V1"
  }
  storage_os_disk {
    name              = "Web-3disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "sysadmin"
    admin_password = "Cybersecurity1"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    owner = "Cameron Todd"
  }
}