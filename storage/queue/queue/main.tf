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


resource "azurerm_storage_account" "this" {
    name = local.storage_account_name
    location            = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "this" {
  name                 = local.queue_name
  storage_account_name = azurerm_storage_account.this.name
}