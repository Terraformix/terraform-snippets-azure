locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  container_app_environment_name = "${var.container_environment_name}"
  container_app__name = "${var.container_app_name}"
}