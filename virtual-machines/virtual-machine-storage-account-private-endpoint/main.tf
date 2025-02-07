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

    "${local.storage_pe_subnet_name}" = {
      subnet_address_prefix = ["10.0.2.0/24"]
    }
  }
}

module "blob_storage_pe" {
  source              = "..//..//modules/private-endpoint"
  resource_name       = "storage"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  subnet_id                      = module.vnet.subnet_details[local.storage_pe_subnet_name].id
  private_connection_resource_id = azurerm_storage_account.this.id
  subresource_name               = "blob"

  private_service_connection_name = "private-service-connection"
  private_dns_zone_group_name     = "private-dns-zone-group"
  private_dns_zone_ids            = [azurerm_private_dns_zone.this.id]
}

resource "azurerm_public_ip" "this" {
  name                = local.vm_config.public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  name                = local.vm_config.nic_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = local.vm_config.nic_ip_config_name
    subnet_id                     = module.vnet.subnet_details[local.default_subnet_name].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = merge(var.common_tags, {})
}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.vm_name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  network_interface_ids = [azurerm_network_interface.this.id]
  size                  = var.vm_sku

  disable_password_authentication = false

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

  # Uncomment to install a sample webapp on the VM
  # custom_data = base64encode(file("../../install-greetify.sh"))

  computer_name  = var.vm_name
  admin_username = var.vm_username
  admin_password = var.vm_password


  tags = merge(var.common_tags, {})
}

resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled    = true
  public_network_access_enabled = false

  tags = merge(var.common_tags, {})
}



resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = local.private_dns_config.vnet_link_name
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = module.vnet.id

  tags = merge(var.common_tags, {})
}