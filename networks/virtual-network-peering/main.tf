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

module "vnet1" {
  source              = "../../modules/virtual-network"
  resource_group_name = azurerm_resource_group.this.name
  name                = local.vnet1_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location

  subnets = {
    "${local.default_subnet_name}" = {
      subnet_address_prefix = ["10.0.1.0/24"]
    }
  }
}

module "vnet2" {
  source              = "../../modules/virtual-network"
  resource_group_name = azurerm_resource_group.this.name
  name                = local.vnet2_name
  address_space       = ["11.0.0.0/16"]
  location            = azurerm_resource_group.this.location

  subnets = {
    "${local.default_subnet_name}" = {
      subnet_address_prefix = ["11.0.1.0/24"]
    }
  }
}

resource "azurerm_virtual_network_peering" "vnet1_to_vnet2" {
  name                      = "${local.vnet1_name}-to-${local.vnet2_name}"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = module.vnet1.name
  remote_virtual_network_id = module.vnet2.id

  # Allows traffic forwarded by a Network Virtual Appliance (NVA) in the remote VNet
  allow_forwarded_traffic = true

  # When true, allows the local VNet to use the remote VNet's gateway for connectivity
  # This is typically used when you want to share an ExpressRoute or VPN gateway
  allow_gateway_transit = false

  # When true, uses the remote VNet's gateway for connectivity
  # This must be false if allow_gateway_transit is true in the remote peering
  use_remote_gateways = false
}

resource "azurerm_virtual_network_peering" "vnet2_to_vnet1" {
  name                      = "${local.vnet2_name}-to-${local.vnet1_name}"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = module.vnet2.name
  remote_virtual_network_id = module.vnet1.id

  # Allows traffic forwarded by a Network Virtual Appliance (NVA) in the remote VNet
  allow_forwarded_traffic = true

  # When true, allows the local VNet to use the remote VNet's gateway for connectivity
  # This is typically used when you want to share an ExpressRoute or VPN gateway
  allow_gateway_transit = false

  # When true, uses the remote VNet's gateway for connectivity
  # This must be false if allow_gateway_transit is true in the remote peering
  use_remote_gateways = false
}