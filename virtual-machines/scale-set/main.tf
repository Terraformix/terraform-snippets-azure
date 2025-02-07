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
        ["allow-http", 100, "Allow", "Tcp", "80", "*", "*"],
        ["allow-ssh", 110, "Allow", "Tcp", "22", "*", "*"]
      ]

    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = var.vmss_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku            = var.vmss_sku
  instances      = local.vmss_config.instances
  admin_username = var.vmss_username
  admin_password = var.vmss_password

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  # Uncomment to install a sample webapp on the VM
  # custom_data = base64encode(file("../../install-greetify.sh"))

  network_interface {
    name    = local.vmss_config.nic_name
    primary = true

    ip_configuration {
      name      = local.vmss_config.nic_ip_config_name
      subnet_id = module.vnet.subnet_details[local.default_subnet_name].id
    }
  }

  tags = merge(var.common_tags, {})
}
