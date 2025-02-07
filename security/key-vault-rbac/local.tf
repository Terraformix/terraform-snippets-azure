locals {
  resource_group_name = "${var.resource_group_name}${random_string.random.result}"

  key_vault_config = {
    name = "${var.key_vault_name}${random_string.random.result}"
    sku  = "standard"
  }
}
