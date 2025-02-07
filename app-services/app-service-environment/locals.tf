locals {
  resource_group_name          = "${var.resource_group_name}${random_string.random.result}"
  app_service_plan_name        = "${var.app_service_plan_name}${random_string.random.result}"
  app_service_name             = "${var.app_service_name}${random_string.random.result}"
  app_service_plan_os          = "Linux"
  app_service_environment_name = "app-environment"
  vnet_name                    = "vnet"
  default_subnet_name          = "default"

}