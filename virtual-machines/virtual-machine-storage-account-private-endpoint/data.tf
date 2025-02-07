data "azurerm_private_endpoint_connection" "storage_account_endpoint_connection" {
  name                = module.blob_storage_pe.name
  resource_group_name = azurerm_resource_group.this.name
  depends_on          = [azurerm_storage_account.this]
}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}
