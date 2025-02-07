locals {
  resource_group_name   = "${var.resource_group_name}${random_string.random.result}"
  app_service_plan_name = "${var.asp_name}${random_string.random.result}"
  app_service_name      = "${var.app_name}${random_string.random.result}"
}