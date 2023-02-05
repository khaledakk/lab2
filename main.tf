resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "rg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "nsr" {
  name                        = "allow_ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rg.name
}
resource "random_password" "admin_password" {
  length  = 20
  special = true
}
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = var.vm1_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm1_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin_password.result
  admin_ssh_key {
    username   = "khaled"
    public_key = file("~/.ssh/id_rsa.pub")
  } #  admin_password        = var.admin_password
  #  disable_password_auth = false
  network_interface_ids = [azurerm_network_interface.vm1_nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL-HA"
    sku       = "7.4"
    version   = "7.4.2019062021"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = var.vm2_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm2_size
  admin_username      = var.admin_username
  admin_password      = random_password.admin_password.result
  admin_ssh_key {
    username   = "khaled"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  #  admin_password        = var.admin_password
  #  disable_password_auth = false
  network_interface_ids = [azurerm_network_interface.vm2_nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "0.20190705.396"
  }
}

resource "azurerm_network_interface" "vm1_nic" {
  name                = "${var.vm1_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1_public_ip.id
  }
}

resource "azurerm_network_interface" "vm2_nic" {
  name                = "${var.vm2_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = ""
  }
}

resource "azurerm_public_ip" "vm1_public_ip" {
  name                    = "${var.vm1_name}-publicip"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
  domain_name_label       = "vmrheldns"
}

resource "azurerm_managed_disk" "disk" {
  name                 = var.disk_name
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
}

resource "azurerm_virtual_machine_extension" "vm2_disk" {
  name                 = "disk"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm2.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings             = <<SETTINGS
    {
        "diskUris": ["${azurerm_managed_disk.disk.id}"]
    }
SETTINGS
  depends_on           = [azurerm_managed_disk.disk]
}

