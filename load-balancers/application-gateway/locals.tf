locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  vnet_name           = "vnet"
  vmss_subnet_name    = "vmss"
  appgw_subnet_name   = "appgw"

  appgw_fe_public_ip_name         = "${var.appgw_name}-fe-pip"
  appgw_ip_config_name            = "${var.appgw_name}-configuration"
  appgw_fe_http_port_name         = "${var.appgw_name}-fe-http-port"
  appgw_fe_https_port_name        = "${var.appgw_name}-fe-https-port"
  appgw_fe_ip_configuration_name  = "${var.appgw_name}-fe-ip"
  appgw_http_listener_name        = "${var.appgw_name}-http-listener"
  appgw_request_routing_rule_name = "${var.appgw_name}-rqrt-rule"
  appgw_path_map_name             = "${var.appgw_name}-path-map"

  # Backend Pools
  appgw_backend_pools = {
    (var.vmss_weather_name) = { name = "${var.appgw_name}-${var.vmss_weather_name}-be-pool" }
    (var.vmss_news_name)    = { name = "${var.appgw_name}-${var.vmss_news_name}-be-pool" }
  }

  # Backend HTTP Settings
  appgw_backend_http_settings = {
    (var.vmss_weather_name) = { name = "${var.appgw_name}-${var.vmss_weather_name}-be-http-settings" }
    (var.vmss_news_name)    = { name = "${var.appgw_name}-${var.vmss_news_name}-be-http-settings" }
  }

  # Health Probes
  appgw_probes = {
    (var.vmss_weather_name) = { name = "${var.vmss_weather_name}-probe", port = 80, request_path = "/healthz" }
    (var.vmss_news_name)    = { name = "${var.vmss_news_name}-probe", port = 80, request_path = "/healthz" }
  }

  vmss_configs = {
    (var.vmss_weather_name) = {
      name               = var.vmss_weather_name
      script_name        = "${var.vmss_weather_name}-script.sh"
      nic_name           = "${var.vmss_weather_name}-nic"
      nic_ip_config_name = "${var.vmss_weather_name}-nic-ip-config"
      instances          = 2
      min_instances      = 2
      max_instances      = 2
      vm_sku             = "Standard_B2s"
    }

    (var.vmss_news_name) = {
      name               = var.vmss_news_name
      script_name        = "${var.vmss_news_name}-script.sh"
      nic_name           = "${var.vmss_news_name}-nic"
      nic_ip_config_name = "${var.vmss_news_name}-nic-ip-config"
      instances          = 1
      min_instances      = 1
      max_instances      = 1
      vm_sku             = "Standard_D2_v3"
    }
  }
}
