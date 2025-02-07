locals {
    resource_group_name = "${var.resource_group_name}${random_string.random.result}"
    storage_account_name = "${var.storage_account_name}${random_string.random.result}"
    queue_name = "fruits"

}