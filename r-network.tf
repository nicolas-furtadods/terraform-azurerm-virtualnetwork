resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.naming}-001"
  address_space       = var.vnet_cidr_block
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  for_each                                       = var.subnets
  name                                           = each.value.shortname == "bastion" ? "AzureBastionSubnet" : "snet-${local.naming_noapplication}-${each.value.shortname}-001"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = tolist([each.value.cidr])
  enforce_private_link_service_network_policies  = each.value.enforce_private_link_service_network_policies
  enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
  service_endpoints                              = each.value.service_endpoints
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

/*
resource "azurerm_network_watcher_flow_log" "flow_logs" {
  for_each = {
    for k, subnet in var.subnets : k => subnet if var.diagnostic_settings != null
  }
  network_watcher_name      = var.diagnostic_settings.network_watcher.network_watcher_name
  resource_group_name       = var.diagnostic_settings.network_watcher.network_watcher_resource_group_name
  location                  = var.location
  tags                      = var.tags
  name                      = "${azurerm_network_security_group.nsg[each.key].name}${var.resource_group_name}-flowlog"
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  storage_account_id = var.diagnostic_settings.storage_account.storage_account_id
  enabled            = true
  version            = 2

  retention_policy {
    enabled = true
    days    = var.diagnostic_settings.storage_account.retention_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.diagnostic_settings.log_analytics.workspace_id
    workspace_region      = var.diagnostic_settings.log_analytics.workspace_region
    workspace_resource_id = var.diagnostic_settings.log_analytics.workspace_resource_id
    interval_in_minutes   = var.diagnostic_settings.log_analytics.interval_in_minutes
  }
}
*/