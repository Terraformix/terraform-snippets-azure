resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}


resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = merge(var.common_tags, {})
}

module "vnet" {
  source              = "../../modules/virtual-network"
  resource_group_name = azurerm_resource_group.this.name
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location

  bastion_subnet_address_prefix = ["10.0.1.0/27"]

  subnets = {
    "${local.default_subnet_name}" = {
      subnet_address_prefix = ["10.0.0.0/24"]

      nsg_inbound_rules = [
        # [name, priority, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        ["allow-rdp", 100, "Allow", "Tcp", "3389", "*", "*"],
        ["allow-ssh", 110, "Allow", "Tcp", "22", "*", "*"]
      ]
    }
  }

}

resource "azurerm_public_ip" "this" {
  name                = local.bastion_config.public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.common_tags, {})
}

resource "azurerm_network_interface" "this" {
  name                = local.vm_config.nic_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_details[local.default_subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(var.common_tags, {})
}


resource "azurerm_bastion_host" "this" {
  name                = var.bastion_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku         = var.bastion_sku
  scale_units = local.bastion_config.scale_units

  ip_configuration {
    name                 = local.bastion_config.ip_config_name
    subnet_id            = module.vnet.subnet_details[local.bastion_subnet_name].id
    public_ip_address_id = azurerm_public_ip.this.id
  }

}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.vm_name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.this.id]
  size                  = var.vm_sku

  os_disk {
    name                 = local.vm_config.disk_name
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }


  computer_name  = var.vm_name
  admin_username = var.vm_username
  admin_password = var.vm_password


  disable_password_authentication = false
}