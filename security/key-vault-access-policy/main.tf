resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = merge(var.common_tags, {})
}


resource "azurerm_key_vault" "this" {
  name                        = local.key_vault_config.name
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = local.key_vault_config.sku

  access_policy {
    tenant_id = var.tenant_id

    # Get the Service Principals Object/Principal ID to Assign the Access Policy to, set this value in the .tfvars file
    # az role assignment list --assignee <client_id> --query "[0].principalId" -o tsv
    object_id = var.object_id

    key_permissions = [
      "Get"
    ]

    secret_permissions = [
      "Get"
    ]

    storage_permissions = [
      "Get"
    ]
  }
}