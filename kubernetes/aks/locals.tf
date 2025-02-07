locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  vnet_name           = "vnet"
  default_subnet_name = "default"

  cluster_config = {
    name       = "${var.cluster_name}${random_string.random.result}"
    dns_prefix = "${var.cluster_name}-dns"
    sku_tier   = "Free"

    network = {
      network_plugin    = "azure"
      load_balancer_sku = "standard"
      dns_service_ip    = "10.0.2.10"
      service_cidr      = "10.0.2.0/24"
    }

    default_node_pool = {
      name       = "default"
      vm_sku     = "Standard_D2_v3"
      node_count = 1
    }

    secondary_node_pools = {
      user = {
        vm_sku              = "Standard_B2s"
        node_count          = 1
        min_node_count      = 1
        max_node_count      = 2
        enable_auto_scaling = true
      }
    }
  }

}