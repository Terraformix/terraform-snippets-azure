resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}


resource "azurerm_resource_group" "this" {
    name = local.resource_group_name
    location = var.location
    tags = merge(var.common_tags, {})
}

resource "azurerm_container_group" "this" {
  name                = local.container_instance_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "Public"
  dns_name_label      = "${local.container_instance_name}-dns"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "nginxdemos/hello:latest"
    cpu    = "1"
    memory = "2"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = merge(var.common_tags, {})

}