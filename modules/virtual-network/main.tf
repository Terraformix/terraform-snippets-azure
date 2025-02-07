resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  address_space       = var.address_space
  resource_group_name = var.resource_group_name

  tags = merge(var.common_tags, {})
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.subnet_address_prefix

  service_endpoints                             = each.value.service_endpoints
  service_endpoint_policy_ids                   = each.value.service_endpoint_policy_ids
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

}

resource "azurerm_subnet" "firewall" {
  count                = var.firewall_subnet_address_prefix != null ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.firewall_subnet_address_prefix
}

resource "azurerm_subnet" "bastion" {
  count                = var.bastion_subnet_address_prefix != null ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.bastion_subnet_address_prefix
}

resource "azurerm_subnet" "gateway" {
  count                = var.gateway_subnet_address_prefix != null ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.gateway_subnet_address_prefix
}

resource "azurerm_network_security_group" "this" {

  // Ensure we only create an NSG if there are security rules (inbound/outbound) explicity passed in when using the module
  for_each = {
    for key, subnet in var.subnets : key => subnet
    if length(coalesce(lookup(subnet, "nsg_inbound_rules", []), [])) > 0 || length(coalesce(lookup(subnet, "nsg_outbound_rules", []), [])) > 0
  }


  name                = lower("${each.key}-nsg") # Uses name of subnet as a prefix
  resource_group_name = var.resource_group_name
  location            = var.location

  # Inbound NSG Rules
  dynamic "security_rule" {
    for_each = coalesce(each.value.nsg_inbound_rules, [])

    content {
      name                       = "${security_rule.value[0]}-inbound"
      priority                   = security_rule.value[1]
      direction                  = "Inbound"
      access                     = security_rule.value[2]
      protocol                   = security_rule.value[3]
      source_port_range          = "*"
      destination_port_range     = security_rule.value[4]
      source_address_prefix      = security_rule.value[5]
      destination_address_prefix = security_rule.value[6]
      description                = "inbound_port_${security_rule.value[4]}"
    }
  }

  # Outbound NSG Rules
  dynamic "security_rule" {
    for_each = coalesce(each.value.nsg_outbound_rules, [])
    
    content {
      name                       = "${security_rule.value[0]}-outbound"
      priority                   = security_rule.value[1]
      direction                  = "Outbound"
      access                     = security_rule.value[2]
      protocol                   = security_rule.value[3]
      source_port_range          = "*"
      destination_port_range     = security_rule.value[4]
      source_address_prefix      = security_rule.value[5]
      destination_address_prefix = security_rule.value[6]
      description                = "outbound_port_${security_rule.value[4]}"
    }
  }

  tags = merge(var.common_tags, {})
}

resource "azurerm_subnet_network_security_group_association" "this" {

  // Ensure we only create a subnet association with an NSG if there are security rules (inbound/outbound) explicity passed in when using the module
  for_each = {
    for key, subnet in var.subnets : key => subnet
    if length(coalesce(lookup(subnet, "nsg_inbound_rules", []), [])) > 0 || length(coalesce(lookup(subnet, "nsg_outbound_rules", []), [])) > 0
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}