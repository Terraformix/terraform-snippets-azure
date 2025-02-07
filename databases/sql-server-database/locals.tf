locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"
  sqlserver_name      = "${var.sqlserver_name}${random_string.random.result}"
  sqldb_name          = "db"
}