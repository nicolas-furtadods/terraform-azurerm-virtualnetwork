variable "subscription_id" {
  description = "ID of the subscription where resources will be created"
}

variable "application" {
  description = "Name of the application for which the virtual network is created (agw,corenet etc.)"
  type        = string
}

variable "technical_zone" {
  description = "Enter a technical zone which will be used by resources (in,ex,cm,sh)"
  type        = string
}
variable "environment" {
  description = "Enter the environment which will be used by resources (hpr,sbx,prd,hyb)"
  type        = string
}

variable "location" {
  description = "Enter the region for which to create the resources."
}

variable "tags" {
  description = "Tags to apply to your resources"
  type        = map(string)
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_cidr_block" {
  description = "CIDR block for VNET"
  type        = list(string)
}

variable "subnets" {
  description = "Map of resources and security rules"
  type = map(object({
    shortname                                      = string
    cidr                                           = string
    enforce_private_link_service_network_policies  = bool
    enforce_private_link_endpoint_network_policies = bool
    service_endpoints                              = list(string)
    template                                       = string
    delegation = list(object({
      name = string
      service_delegation = list(object({
        name    = string       # (Required) The name of service to delegate to. Possible values include Microsoft.BareMetal/AzureVMware, Microsoft.BareMetal/CrayServers, Microsoft.Batch/batchAccounts, Microsoft.ContainerInstance/containerGroups, Microsoft.Databricks/workspaces, Microsoft.HardwareSecurityModules/dedicatedHSMs, Microsoft.Logic/integrationServiceEnvironments, Microsoft.Netapp/volumes, Microsoft.ServiceFabricMesh/networks, Microsoft.Sql/managedInstances, Microsoft.Sql/servers, Microsoft.Web/hostingEnvironments and Microsoft.Web/serverFarms.
        actions = list(string) # (Required) A list of Actions which should be delegated. Possible values include Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action, Microsoft.Network/virtualNetworks/subnets/action and Microsoft.Network/virtualNetworks/subnets/join/action.
      }))
    }))
  }))
}

variable "template_folder" {
  description = "A folder containing Network Security Rules as JSON. To use a file, you must call it by name."
  type        = string
  default     = null
}

variable "diagnostic_settings" {
  description = "Object structure for information regarding diagnostics settings"
  type = object({
    subscription_id = string
    network_watcher = object({
      network_watcher_name                = string
      network_watcher_resource_group_name = string
    })
    log_analytics = object({
      workspace_id          = string
      workspace_resource_id = string
      workspace_region      = string
      interval_in_minutes   = number
    })
    storage_account = object({
      storage_account_id = string
      retention_days     = number
    })
  })
  default = null
}