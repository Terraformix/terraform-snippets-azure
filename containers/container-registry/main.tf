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

resource "azurerm_container_registry" "this" {
  name = local.container_registry_name
  location         = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku = "Standard"

  admin_enabled                 = true
}