##########################################################################
# Virtual Network and Subnets
##########################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.naming}-001"
  address_space       = var.vnet_cidr_block
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_virtual_network_dns_servers" "dns" {
  count              = length(var.vnet_dns_server) > 0 ? 1 : 0
  virtual_network_id = azurerm_virtual_network.vnet.id
  dns_servers        = var.vnet_dns_server
}

resource "azurerm_subnet" "subnet" {
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  for_each                                      = var.subnets
  name                                          = contains(local.reserved_subnets, each.value.shortname) ? each.value.shortname : "snet-${local.naming_noapplication}-${each.value.shortname}-001"
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = tolist([each.value.cidr])
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  service_endpoints                             = each.value.service_endpoints
  dynamic "delegation" {
    for_each = each.value.delegation
    iterator = delegation
    content {
      name = delegation.value.name
      dynamic "service_delegation" {
        for_each = delegation.value.service_delegation
        iterator = service_delegation
        content {
          name    = service_delegation.value.name    # (Required) The name of service to delegate to. Possible values include Microsoft.BareMetal/AzureVMware, Microsoft.BareMetal/CrayServers, Microsoft.Batch/batchAccounts, Microsoft.ContainerInstance/containerGroups, Microsoft.Databricks/workspaces, Microsoft.HardwareSecurityModules/dedicatedHSMs, Microsoft.Logic/integrationServiceEnvironments, Microsoft.Netapp/volumes, Microsoft.ServiceFabricMesh/networks, Microsoft.Sql/managedInstances, Microsoft.Sql/servers, Microsoft.Web/hostingEnvironments and Microsoft.Web/serverFarms.
          actions = service_delegation.value.actions # (Required) A list of Actions which should be delegated. Possible values include Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action, Microsoft.Network/virtualNetworks/subnets/action and Microsoft.Network/virtualNetworks/subnets/join/action.
        }
      }
    }
  }

}

##########################################################################
# Network Security Group
##########################################################################

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = "nsg-snet-${local.naming}-${each.value.shortname}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "templates" {
  source = "./Security Rules"
  for_each = {
    for k, subnet in var.subnets : k => subnet if var.template_folder != null && var.template_folder != "" && subnet.template != null && subnet.template != ""
  }
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
  rules_file                  = lookup(local.template_map, each.value.template)
}


resource "azurerm_subnet_network_security_group_association" "nsgsub" {
  depends_on = [
    module.templates
  ]
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

}


##########################################################################
# NAT Gateway
##########################################################################

resource "azurerm_public_ip" "nat_ip" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "pip-${local.naming}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gw" {
  count                   = var.enable_nat_gateway ? 1 : 0
  name                    = "nat-${local.naming}-001"
  resource_group_name     = var.resource_group_name
  location                = var.location
  tags                    = var.tags
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_ip_assoc" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat_gw[0].id
  public_ip_address_id = azurerm_public_ip.nat_ip[0].id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_assoc" {
  for_each = {
    for k, subnet in azurerm_subnet.subnet :
    k => subnet if azurerm_subnet.subnet[k].name != "gateway_subnet" && var.enable_nat_gateway
  }
  subnet_id      = azurerm_subnet.subnet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gw[0].id
}