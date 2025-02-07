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

  subnets = {
    "${local.default_subnet_name}" = {
      subnet_address_prefix = ["10.0.1.0/24"]
      nsg_inbound_rules = [
        # [name, priority, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        ["allow-ssh", 110, "Allow", "Tcp", "22", "*", "*"]
      ]

    }
  }
}

resource "azurerm_network_interface" "this" {
  count = local.vm_count

  name                = local.vm_config.nic_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = local.vm_config.nic_ip_config_name
    subnet_id                     = module.vnet.subnet_details[local.default_subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  count = local.vm_count

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

resource "azurerm_private_dns_zone" "this" {
  name                = local.private_dns_config.name
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = local.private_dns_config.vnet_link_name
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = module.vnet.id
}

resource "azurerm_private_dns_a_record" "this" {
  count               = local.vm_count
  name                = "${var.vm_name}${count.index}"
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = [azurerm_network_interface.this[count.index].private_ip_address]
}