locals {
  resource_group_name  = "${var.resource_group_name}${random_string.random.result}"
  storage_account_name = "${var.storage_account_name}${random_string.random.result}"
  container_name       = "fruits"

  vnet_name           = "vnet"
  default_subnet_name = "default"

  vm_config = {
    name               = var.vm_name
    disk_name          = "${var.vm_name}-disk"
    public_ip_name     = "${var.vm_name}-pip"
    nic_name           = "${var.vm_name}-nic"
    nic_ip_config_name = "${var.vm_name}-nic-ip-config"
  }

}
