locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  vnet_name           = "vnet"
  default_subnet_name = "default"

  vmss_config = {
    name               = var.vmss_name
    instances          = 1
    min_instances      = 1
    max_instances      = 2
    disk_name          = "${var.vmss_name}-disk"
    public_ip_name     = "${var.vmss_name}-pip"
    nic_name           = "${var.vmss_name}-nic"
    nic_ip_config_name = "${var.vmss_name}-nic-ip-config"
  }
}
