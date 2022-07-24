resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.naming}-001"
  address_space       = var.vnet_cidr_block
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each                                       = var.subnets
  name                                           = each.value.shortname == "bastion" ? "AzureBastionSubnet" : "snet-${local.naming}-${each.value.shortname}"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = tolist([each.value.cidr])
  enforce_private_link_service_network_policies  = each.value.private_link_policy
  enforce_private_link_endpoint_network_policies = each.value.private_endpoint_policy
}