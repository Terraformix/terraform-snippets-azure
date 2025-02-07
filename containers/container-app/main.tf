resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
    name = local.resource_group_name
    location = var.location
    tags = merge({}, var.common_tags)
}


resource "azurerm_container_app_environment" "this" {
  name = local.container_app_environment_name
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = merge({}, var.common_tags)
}

resource "azurerm_container_app" "this" {
  name = local.container_app__name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name = azurerm_resource_group.this.name
  revision_mode = "Single"

  ingress {
    target_port = 80
    external_enabled = true
    
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = local.container_app__name
      image  = "nginxdemos/hello:latest"
      cpu    = 1
      memory = "2Gi"
    }
  }

  tags = merge({}, var.common_tags)
}