locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  container_registry_name = "${var.container_registry_name}${random_string.random.result}"
}