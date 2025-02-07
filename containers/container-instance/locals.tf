locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  container_instance_name = "${var.container_instance_name}"
}