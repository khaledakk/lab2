variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "vm1_name" {
  description = "Name of the Azure VM for RHEL"
  type        = string
}

variable "vm2_name" {
  description = "Name of the Azure VM for Debian"
  type        = string
}


variable "vm1_size" {
  description = "Size of RHEL VM"
  type        = string
}

variable "vm2_size" {
  description = "Size of Debian VM"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
}

variable "admin_username" {
  description = "Username of the admin user"
  type        = string
}

variable "admin_password" {
  description = "Password of the admin user"
  type        = string
}
variable "disk_name" {
  description = "Name of the disk"
  type        = string
}

variable "disk_size" {
  description = "Size of the disk"
  type        = number
}

