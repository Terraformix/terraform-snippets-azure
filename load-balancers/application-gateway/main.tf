resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}${random_string.random.result}"
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
    "${local.vmss_subnet_name}" = {
      subnet_address_prefix = ["10.0.0.0/24"]

      nsg_inbound_rules = [
        # [name, priority, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        ["allow-http", 100, "Allow", "Tcp", "80", "*", "*"],
      ]
    }

    "${local.appgw_subnet_name}" = {
      subnet_address_prefix = ["10.0.1.0/24"]

      nsg_inbound_rules = [
        # [name, priority, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        ["allow-http", 100, "Allow", "Tcp", "80", "*", "*"],
      ]
    }
  }

}

resource "azurerm_public_ip" "this" {
  name                = local.appgw_fe_public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = var.appgw_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku {
    name     = var.appgw_sku
    tier     = var.appgw_sku
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.appgw_ip_config_name
    subnet_id = module.vnet.subnet_details[local.appgw_subnet_name].id
  }

  frontend_port {
    name = local.appgw_fe_http_port_name
    port = 80
  }

  frontend_port {
    name = local.appgw_fe_https_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.appgw_fe_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  dynamic "backend_address_pool" {
    for_each = local.vmss_configs

    content {
      name = local.appgw_backend_pools[backend_address_pool.key].name
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.vmss_configs

    content {
      name                  = local.appgw_backend_http_settings[backend_http_settings.key].name
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
      probe_name            = local.appgw_probes[backend_http_settings.key].name
    }
  }

  dynamic "probe" {
    for_each = local.vmss_configs

    content {
      name                = local.appgw_probes[probe.key].name
      protocol            = "Http"
      path                = local.appgw_probes[probe.key].request_path
      interval            = 45
      timeout             = 45
      unhealthy_threshold = 3
      host                = "127.0.0.1"
      match {
        status_code = ["200"]
        body        = "healthy"
      }
    }
  }

  request_routing_rule {
    name               = local.appgw_request_routing_rule_name
    priority           = 1
    rule_type          = "PathBasedRouting"
    http_listener_name = local.appgw_http_listener_name
    url_path_map_name  = local.appgw_path_map_name

  }

  http_listener {
    name                           = local.appgw_http_listener_name
    frontend_ip_configuration_name = local.appgw_fe_ip_configuration_name
    frontend_port_name             = local.appgw_fe_http_port_name
    protocol                       = "Http"
  }

  url_path_map {
    name                               = local.appgw_path_map_name
    default_backend_address_pool_name  = local.appgw_backend_pools[var.vmss_weather_name].name
    default_backend_http_settings_name = local.appgw_backend_http_settings[var.vmss_weather_name].name

    path_rule {
      name                       = "weather-path"
      paths                      = ["/weather/*"]
      backend_address_pool_name  = local.appgw_backend_pools[var.vmss_weather_name].name
      backend_http_settings_name = local.appgw_backend_http_settings[var.vmss_weather_name].name
    }

    path_rule {
      name                       = "news-path"
      paths                      = ["/news/*"]
      backend_address_pool_name  = local.appgw_backend_pools[var.vmss_news_name].name
      backend_http_settings_name = local.appgw_backend_http_settings[var.vmss_news_name].name
    }
  }
}


resource "azurerm_linux_virtual_machine_scale_set" "this" {
  for_each = local.vmss_configs

  name                = each.value.name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = each.value.vm_sku
  instances           = each.value.instances

  disable_password_authentication = false
  computer_name_prefix            = each.value.name
  admin_username                  = var.vmss_username
  admin_password                  = var.vmss_password

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = base64encode(file("../../${each.value.script_name}"))

  network_interface {
    name    = each.value.nic_name
    primary = true

    ip_configuration {
      name      = each.value.nic_ip_config_name
      primary   = true
      subnet_id = module.vnet.subnet_details[local.vmss_subnet_name].id

      application_gateway_backend_address_pool_ids = [
        for pool in azurerm_application_gateway.this.backend_address_pool : pool.id
        if pool.name == local.appgw_backend_pools[each.key].name
      ]
    }
  }
}