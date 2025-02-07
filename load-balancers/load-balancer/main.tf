resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location

  tags = var.common_tags
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

      nsg_inbound_rules = [
        # [name, priority, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        ["allow-http", 100, "Allow", "Tcp", "80", "*", "*"],
        ["allow-ssh", 110, "Allow", "Tcp", "22", "*", "*"],
      ]

    }

  }

}

resource "azurerm_public_ip" "lb" {
  name                = local.lb_fe_public_ip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = var.lb_sku

  tags = var.common_tags
}

resource "azurerm_lb" "this" {
  name                = var.lb_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.lb_sku

  frontend_ip_configuration {
    name                 = local.lb_fe_ip_config_name
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = var.common_tags
}

resource "azurerm_lb_backend_address_pool" "pools" {
  for_each = local.lb_backend_pools

  name            = each.value.name
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "probes" {
  for_each = local.lb_probes

  name                = each.value.name
  loadbalancer_id     = azurerm_lb.this.id
  port                = each.value.port
  protocol            = "Http"
  request_path        = each.value.request_path
  interval_in_seconds = 30
}

resource "azurerm_lb_rule" "rules" {
  for_each = local.lb_rules

  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = local.lb_fe_ip_config_name
  probe_id                       = azurerm_lb_probe.probes[each.key].id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pools[each.key].id]
}

resource "azurerm_lb_nat_rule" "nat_rules" {
  for_each = local.lb_nat_rules

  name                           = each.value.name
  resource_group_name            = azurerm_resource_group.this.name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = "Tcp"
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = local.lb_fe_ip_config_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pools[each.key].id
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
      name                                   = each.value.nic_ip_config_name
      primary                                = true
      subnet_id                              = module.vnet.subnet_details[local.default_subnet_name].id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.pools[each.key].id]
    }
  }
}
