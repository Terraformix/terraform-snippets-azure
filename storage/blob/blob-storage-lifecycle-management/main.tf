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

resource "azurerm_storage_container" "this" {
    name = local.container_name
    storage_account_name = azurerm_storage_account.this.name
    container_access_type = "blob"
}

resource "azurerm_storage_blob" "apple" {
    name = "apple.jpg"
    storage_account_name = azurerm_storage_account.this.name
    storage_container_name = azurerm_storage_container.this.name

    type = "Block"
    source = "apple.jpg"
}

resource "azurerm_storage_blob" "orange" {
    name = "orange.jpg"
    storage_account_name = azurerm_storage_account.this.name
    storage_container_name = azurerm_storage_container.this.name

    type = "Block"
    source = "orange.jpg"
}

resource "azurerm_storage_management_policy" "this" {
 storage_account_id = azurerm_storage_account.this.id

 dynamic "rule" {
    for_each = local.lifecycle_rules

    content {
      name = rule.key
      enabled = rule.value.enabled
      filters {
        prefix_match = rule.value.prefix_match
        blob_types = rule.value.blob_types
      }
      actions {
        base_blob {
          tier_to_cold_after_days_since_modification_greater_than = rule.value.tier_to_cold_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_days
          delete_after_days_since_modification_greater_than = rule.value.delete_days
        }
      }
    }
 } 
 
}