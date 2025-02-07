locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"

  vnet1_name          = "vnet1"
  vnet2_name          = "vnet2"
  default_subnet_name = "default"

}
