resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}


resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location

  tags = merge({}, var.common_tags)
}

module "vnet" {
  source              = "../../modules/virtual-network"
  resource_group_name = azurerm_resource_group.this.name
  name                = local.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location

  subnets = {
    "${local.default_subnet_name}" = {
      subnet_address_prefix = ["10.0.0.0/24"]

      delegation = {
        name = "appservice-delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action",
          ]
        }
      }
    }
  }

}

resource "azurerm_service_plan" "this" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = var.asp_os
  sku_name            = var.asp_sku

  tags = merge(var.common_tags, {})
}

resource "azurerm_linux_web_app" "this" {
  name                = local.app_service_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id

  virtual_network_subnet_id = module.vnet.subnet_details[var.default_subnet_name].id

  https_only = true

  site_config {}

  tags = merge(var.common_tags, {})

}