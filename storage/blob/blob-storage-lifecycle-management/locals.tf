locals {
    resource_group_name = "${var.resource_group_name}${random_string.random.result}"
    storage_account_name = "${var.storage_account_name_}${random_string.random.result}"
    container_name = "fruits"
    immutability_period_in_days = 14

    lifecycle_rules = {

        rule1 = {
            enabled = true
            prefix_match = ["fruits/apple.jpg"]
            blob_types = ["blockBlob"]
            tier_to_cold_days = 1
            tier_to_archive_days = 5
            delete_days = 10
        }

        rule2 = {
            enabled = true
            prefix_match = ["fruits/orange.jpg"]
            blob_types = ["blockBlob"]
            tier_to_cold_days = 2
            tier_to_archive_days = 7
            delete_days = 14
        }
    }

}