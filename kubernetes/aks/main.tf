module "common_settings" {
  source = "../../modules/common"
}

resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location

  tags = merge(var.common_tags, {})
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
    }
  }
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_config.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku_tier   = local.cluster_config.sku_tier
  dns_prefix = local.cluster_config.dns_prefix

  default_node_pool {
    name           = local.cluster_config.default_node_pool.name
    vm_size        = local.cluster_config.default_node_pool.vm_sku
    node_count     = local.cluster_config.default_node_pool.node_count
    vnet_subnet_id = module.vnet.subnet_details[local.default_subnet_name].id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = local.cluster_config.network.network_plugin
    load_balancer_sku = local.cluster_config.network.load_balancer_sku
    dns_service_ip    = local.cluster_config.network.dns_service_ip
    service_cidr      = local.cluster_config.network.service_cidr
  }


  tags = merge(var.common_tags, {})
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = local.cluster_config.secondary_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_sku
  enable_auto_scaling   = each.value.enable_auto_scaling
  node_count            = each.value.node_count
  min_count             = each.value.min_node_count
  max_count             = each.value.max_node_count

  vnet_subnet_id = module.vnet.subnet_details[local.default_subnet_name].id

  tags = merge(var.common_tags, {})
}