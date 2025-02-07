variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type    = string
  default = "vnet"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "firewall_subnet_address_prefix" {
  type    = list(string)
  default = null
}

variable "firewall_service_endpoints" {
  type = list(string)
  default = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}


variable "bastion_subnet_address_prefix" {
  type    = list(string)
  default = null
}

variable "gateway_subnet_address_prefix" {
  type    = list(string)
  default = null
}

variable "gateway_service_endpoints" {
  type    = list(string)
  default = []
}


variable "subnets" {
  type = map(object({
    subnet_address_prefix                         = list(string)
    service_endpoints                             = optional(list(string), [])
    service_endpoint_policy_ids                   = optional(list(string))
    private_endpoint_network_policies             = optional(string)
    private_link_service_network_policies_enabled = optional(bool)

    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))

    nsg_inbound_rules  = optional(list(list(string)))
    nsg_outbound_rules = optional(list(list(string)))
  }))
}


variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development",
    "Department"  = "IT"
  }
}

