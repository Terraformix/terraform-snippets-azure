locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"

  vnet_name           = "vnet"
  default_subnet_name = "default"

  lb_fe_public_ip_name = "${var.lb_name}-fe-pip"
  lb_fe_ip_config_name = "${var.lb_name}-fe-ip"
  lb_http_probe_name   = "${var.lb_name}-http-probe"


  # Backend Pools
  lb_backend_pools = {
    (var.vmss_weather_name) = { name = "${var.lb_name}-${var.vmss_weather_name}-be-pool" }
    (var.vmss_news_name)    = { name = "${var.lb_name}-${var.vmss_news_name}-be-pool" }
  }

  # Health Probes
  lb_probes = {
    (var.vmss_weather_name) = { name = "${var.vmss_weather_name}-probe", port = 80, request_path = "/healthz" }
    (var.vmss_news_name)    = { name = "${var.vmss_news_name}-probe", port = 80, request_path = "/healthz" }
  }

  # Load Balancer Rules
  lb_rules = {
    (var.vmss_weather_name) = { name = "${var.vmss_weather_name}-rule", frontend_port = 8080, backend_port = 80 }
    (var.vmss_news_name)    = { name = "${var.vmss_news_name}-rule", frontend_port = 9090, backend_port = 80 }
  }

  # Load Balancer Inbound NAT Rules - Allow SSH into backend pools directly without exposing public IP on VMSS
  lb_nat_rules = {
    # Frontend port ranges should take into account the number of instances (Max)
    (var.vmss_weather_name) = { name = "${var.vmss_weather_name}-ssh-nat-rule", frontend_port_start = 2200, frontend_port_end = 2201, backend_port = 22 }
    (var.vmss_news_name)    = { name = "${var.vmss_news_name}-ssh-nat-rule", frontend_port_start = 2202, frontend_port_end = 2202, backend_port = 22 }
  }

  vmss_configs = {
    (var.vmss_weather_name) = {
      name                  = var.vmss_weather_name
      script_name           = "${var.vmss_weather_name}-script.sh"
      nic_name              = "${var.vmss_weather_name}-nic"
      nic_ip_config_name    = "${var.vmss_weather_name}-nic-ip-config"
      instances             = 2
      min_instances         = 1
      max_instances         = 2
      ssh_fe_nat_port_start = 2200
      ssh_fe_nat_port_start = 2210
      vm_sku                = "Standard_B2s"
    }

    (var.vmss_news_name) = {
      name                  = var.vmss_news_name
      script_name           = "${var.vmss_news_name}-script.sh"
      nic_name              = "${var.vmss_news_name}-nic"
      nic_ip_config_name    = "${var.vmss_news_name}-nic-ip-config"
      instances             = 1
      min_instances         = 1
      max_instances         = 1
      ssh_fe_nat_port_start = 2220
      ssh_fe_nat_port_start = 2230
      vm_sku                = "Standard_D2_v3"
    }
  }
}
