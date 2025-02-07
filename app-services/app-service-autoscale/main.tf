resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location

  tags = merge(var.common_tags, {})
}

resource "azurerm_service_plan" "this" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = var.asp_os
  sku_name            = var.asp_sku

  tags = merge(var.common_tags, {})
}

resource "azurerm_linux_web_app" "this" {
  name                = local.app_service_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  site_config {}

  tags = merge(var.common_tags, {})

}

resource "azurerm_monitor_autoscale_setting" "this" {
  name                = "autoscale"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  target_resource_id  = azurerm_service_plan.this.id

  profile {
    name = "default"

    capacity {
      default = 2
      minimum = 2
      maximum = 5
    }

    // Scale out rule
    rule {

      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT15M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }


    // Scale in rule
    rule {

      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT15M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

  }

  notification {
    email {
      custom_emails = ["johndoe@gmail.com"]
    }
  }

  tags = merge(var.common_tags, {})
}