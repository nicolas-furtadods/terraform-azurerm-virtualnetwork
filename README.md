# Azure Policies
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This Terraform feature creates a standalone [Azure Virtual Network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview), allowing you to deploy a virtual network and dependencies. It helps you to deploy security rules on specific network security groups using the template feature..

## Version compatibility

| Module version | Terraform version | AzureRM version |
|----------------|-------------------|-----------------|
| >= 1.x.x       | 1.1.0             | >= 3.12         |

## Usage

### Global Module Configuration
```hcl
resource "azurerm_resource_group" "rg" {
  name     = "<your_rg_name>"
  location = "francecentral"
  tags = {
    "Application"        = "azuretesting",
  }
}

module "vnet" {
  source = "./terraform-azurerm-virtualnetwork" # Your path may be different.
  
  # Mandatory Parameters
  application         = "azuretesting"
  environment         = "poc"
  location            = "francecentral"
  resource_group_name = azurerm_resource_group.core_rg.name
  technical_zone      = "cm"
  tags = {
    "Application"        = "azuretesting",
  }
  vnet_cidr_block     = ["10.1.0.0/16"]
  

  subnets = {
    "agw" : {
      shortname                                      = "agw"
      cidr                                           = "10.1.0.0/24"
      enforce_private_link_service_network_policies  = false
      enforce_private_link_endpoint_network_policies = false
      service_endpoints                              = []
      delegation                                     = []
      template                                       = "Azure Application Gateway"
    }
    "privateendpoint" : {
      shortname                                      = "privatendpoint"
      cidr                                           = "10.1.1.0/24"
      enforce_private_link_service_network_policies  = false
      enforce_private_link_endpoint_network_policies = true
      service_endpoints                              = []
      delegation                                     = []
      template                                       = null
    }
  }

  # Optional. You must specify a folder with json file to use the 'template' attribute of the subnet map.
  template_folder = "./NSG Templates Rules"

  # Optional. Specify DNS server if you don't use Azure provided DNS
  vnet_dns_server     = ["10.7.7.2", "10.7.7.7", "10.7.7.1"]
}
```

## Arguments Reference

The following arguments are supported:
  - `application` - (Required) Name of the application for which the virtual network is created (agw,corenet etc.).
  - `environment` - (Required) A 3-digits environment which will be used by resources (hpr,sbx,prd,hyb).
  - `location` - (Required) The region for which to create the resources.
  - `resource_group_name` - (Required) Name of the resource group where resources will be created.
  - `subnet` - (Required) A map of `subnet`as defined below.
  - `technical_zone` - (Required) A 2-digits technical zone which will be used by resources (in,ex,cm,sh).
  - `vnet_cidr_block` - (Required) A string list of CIDR blocks.


##
  - `template_folder` - (Optional) A folder containing Network Security Rules as JSON. To use a file, you must call it by name. This is 
| ⚠ This is required when you want to use `subnet.template` attribute |
|--------------------------------------------------------------------------------------|
  - `initiatives_parameters` - (Optional)  A `initiatives_parameters` map as defined below.
  - `predefined_initiatives` - (Optional)  A map of `predefined_initiatives` object as defined below.
  - `predefined_policies` - (Optional)  A map of `predefined_policies` object as defined below.
  - `tags` - (Optional) A key-value map of string.
  
##
A `delegation` object support the following:
  - `name` - (Required) A name for this delegation.
  - `service_delegation` - (Required) A `service_delegation` block as defined below.

##
A `diagnostic_settings` object support the following:
  - `subscription_id` - (Required) Policy Parameters as JSON string.
  - `log_analytics` - (Required) A `log_analytics` object as defined below.
  - `network_watcher` - (Required) A `network_watcher` object as defined below.
  - `storage_account` - (Required) A `storage_account` object as defined below.

##
A `log_analytics` object support the following:
  - `interval_in_minutes` - (Required) How frequently service should do flow analytics in minutes.
  - `workspace_id` - (Required) The resource GUID of the attached workspace.
  - `workspace_region` - (Required) The location of the attached workspace.
  - `workspace_resource_id` - (Required) The resource ID of the attached workspace.

##
A `network_watcher` object support the following:
  - `network_watcher_name` - (Required) The name of the Network Watcher. Changing this forces a new resource to be created.
  - `network_watcher_resource_group_name` - (Required) The name of the resource group in which the Network Watcher was deployed. Changing this forces a new resource to be created.

##
A `service_delegation` object support the following:
  - `name` - (Required) The name of service to delegate to. Possible values include `Microsoft.ApiManagement/service`, `Microsoft.AzureCosmosDB/clusters`, `Microsoft.BareMetal/AzureVMware`, `Microsoft.BareMetal/CrayServers`, `Microsoft.Batch/batchAccounts`, `Microsoft.ContainerInstance/containerGroups`, `Microsoft.ContainerService/managedClusters`, `Microsoft.Databricks/workspaces`, `Microsoft.DBforMySQL/flexibleServers`, `Microsoft.DBforMySQL/serversv2`, `Microsoft.DBforPostgreSQL/flexibleServers`, `Microsoft.DBforPostgreSQL/serversv2`, `Microsoft.DBforPostgreSQL/singleServers`, `Microsoft.HardwareSecurityModules/dedicatedHSMs`, `Microsoft.Kusto/clusters`, `Microsoft.Logic/integrationServiceEnvironments`, `Microsoft.MachineLearningServices/workspaces, Microsoft.Netapp/volumes, Microsoft.Network/managedResolvers, Microsoft.PowerPlatform/vnetaccesslinks, Microsoft.ServiceFabricMesh/networks, Microsoft.Sql/managedInstances`, `Microsoft.Sql/servers`, `Microsoft.StoragePool/diskPools`, `Microsoft.StreamAnalytics/streamingJobs`, `Microsoft.Synapse/workspaces`, `Microsoft.Web/hostingEnvironments`, and `Microsoft.Web/serverFarms`.
  - `actions` - (Required)  A list of Actions which should be delegated. This list is specific to the service to delegate to. Possible values include `Microsoft.Network/networkinterfaces/*`, `Microsoft.Network/virtualNetworks/subnets/action`, `Microsoft.Network/virtualNetworks/subnets/join/action`, `Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action` and `Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action`.

##
A `storage_account` object support the following:
  - `retention_days` - (Required) The number of days to retain flow log records.
  - `storage_account_id` - (Required) The storage account id for flow logs storage.

##
A `subnet` object support the following:
  - `cidr` - (Required) The CIDR for the subnet within the virtual network adress block.
  - `delegation` - (Required) One or more `delegation` object as list as defined below.
  - `enforce_private_link_service_network_policies` - (Required) Enable or Disable network policies for the private link endpoint on the subnet. Setting this to `true` will Disable the policy and setting this to `false` will Enable the policy.
| ⚠ Network policies, like network security groups (NSG), are not supported for Private Link Endpoints or Private Link Services. In order to deploy a Private Link Endpoint on a given subnet, you must set the `enforce_private_link_endpoint_network_policies` attribute to `true`. This setting is only applicable for the Private Link Endpoint, for all other resources in the subnet access is controlled based via the Network Security Group which can be configured using the `azurerm_subnet_network_security_group_association` resource. |
  - `enforce_private_link_service_network_policies` - (Required) Enable or Disable network policies for the private link service on the subnet. Setting this to `true` will Disable the policy and setting this to `false` will Enable the policy. Default value is `false`.
| ⚠ In order to deploy a Private Link Service on a given subnet, you must set the `enforce_private_link_service_network_policies` attribute to `true`. This setting is only applicable for the Private Link Service, for all other resources in the subnet access is controlled based on the Network Security Group which can be configured using the `azurerm_subnet_network_security_group_association` resource. |
|--------------------------------------------------------------------------------------|
  - `service_endpoints` - (Required) The list of Service endpoints to associate with the subnet. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage` and `Microsoft.Web`.
  - `shortname` - (Required) A short name for the subnet. By convention, the subnet will have the following pattern: snet-<technical_zone>-<environnment>-<subnet.shortname>-001.


## Attribute Reference

The following Attributes are exported:
  - `virtual_network` - A `virtual_network` object as defined below.

##
A `virtual_network` block exports the following:
  - `id` - The created Virtual Network ID
  - `name` - The created virtual Network name.
  - `subnets` - A map of `subnet` object as defined below. 

##
A `subnet` block exports the following:
  - `subnet_id` - The subnet ID
  - `address_prefix` - The subnet Adress Prefix.
  - `network_security_group_id` - The Network Security Group ID associated
  - `network_security_group_name` - The Network Security Group Name associated

## References
Please check the following references for best practices.
* [Terraform Best Practices](https://www.terraform-best-practices.com/)
* [Azure Policy as Code with Terraform Part 1](https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1)