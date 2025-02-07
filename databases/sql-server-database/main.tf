resource "random_string" "random" {
  length  = 3
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = merge({}, var.common_tags)
}


resource "azurerm_mssql_server" "this" {
  name                = local.sqlserver_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  version                      = "12.0"
  administrator_login          = var.sqlserver_username
  administrator_login_password = var.sqlserver_password

  tags = merge({}, var.common_tags)

}

resource "azurerm_mssql_database" "this" {
  name         = local.sqldb_name
  server_id    = azurerm_mssql_server.this.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  lifecycle {
    prevent_destroy = true
  }

  tags = merge({}, var.common_tags)
}

resource "azurerm_mssql_firewall_rule" "allow_local_ip" {
  name             = "allow-local-ip"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = data.http.my_ip.body
  end_ip_address   = data.http.my_ip.body
}