locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  vnet_name           = "vnet"
  default_subnet_name = "default"
  bastion_subnet_name = "AzureBastionSubnet"

  bastion_config = {
    name           = var.bastion_name
    disk_name      = "${var.bastion_name}-disk"
    public_ip_name = "${var.bastion_name}-pip"
    ip_config_name = "${var.bastion_name}-ip-config"
    scale_units    = 4
  }

  vm_config = {
    name               = var.vm_name
    disk_name          = "${var.vm_name}-disk"
    nic_name           = "${var.vm_name}-nic"
    nic_ip_config_name = "${var.vm_name}-nic-ip-config"
  }
}
