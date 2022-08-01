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


}
```

## Arguments Reference

The following arguments are supported:
  - `application` - (Required) Name of the application for which the virtual network is created (agw,corenet etc.).
  - `environment` - (Required) A 3-digits environment which will be used by resources (hpr,sbx,prd,hyb).
  - `location` - (Required) The region for which to create the resources.
  - `resource_group_name` - (Required) Name of the resource group where resources will be created.
  - `technical_zone` - (Required) A 2-digits technical zone which will be used by resources (in,ex,cm,sh).
  - `tags` - (Required) A key-value map of string.
  - `vnet_cidr_block` - (Required) A string list of CIDR blocks.

##
  - `custom_policy` - (Optionnal) A `custom_policy` Object as defined below.
  - `initiatives_parameters` - (Optionnal)  A `initiatives_parameters` map as defined below.
  - `predefined_initiatives` - (Optionnal)  A map of `predefined_initiatives` object as defined below.
  - `predefined_policies` - (Optionnal)  A map of `predefined_policies` object as defined below.

##
A `category_exclusive_parameters` object support the following:
  - `initiative_name` - (Required) Name of the initiative to assign.
  - `excluded_scopes` - (Optionnal) List of Management group, subscriptions, resource groups, resources scopes for the specific category. Will be merge with the initiatives global excluded scopes.

##
A `custom_policy` map support the following:
  - `library_folder` - (Required) A folder path containing json files.
  - `policy_excluive_parameters` - (Optionnal) A map of `policy_excluive_parameters` object as defined below.


##
A `identity` object support the following:
  - `type` - (Required) Possible values are `SystemAssigned` or `UserAssigned` .
  - `identity_ids` - (Optionnal) List of Managed Identity IDs. Required when `type` is set to `UserAssigned`.

##
A `initiatives_parameters` object support the following:
  - `default_policies_non_compliant_message` - (Optionnal) Default policy non compliant message.
  - `description` - (Optionnal) Initiative Description.
  - `display_name_prefix` - (Optionnal) Initiative names prefix. Note that the category key will be appended at the end.
  - `excluded_scopes` - (Optionnal) List of Management group, subscriptions, resource groups, resources scopes.
  - `identity` - (Optionnal) . A custom object as defined above
  - `category_exclusive_parameters` - (Optionnal) . A custom map of `category_exclusive_parameters` objects as defined above


##
A `policy_excluive_parameters` object support the following:
  - `parameter_values` - (Optionnal) Policy Parameters as JSON string.
  - `non_compliance_message` - (Optionnal) Policy specific non compliance message.

| ⚠ The key must be the policy name, as the module uses lookup to search for attribute |
|--------------------------------------------------------------------------------------|

##
A `predefined_initiatives` object support the following:
  - `initiative_name` - (Required) The name of the initiative to implement
  - `exemption_reference_list` - (Optionnal) List of policies reference ids in the initiative that you want exempted.

##
A `predefined_policies` object support the following:
  - `display_name` - (Required) The display name of the Policy.
  - `name` - (Required) The ID/Name of the policy definition.
  - `category` - (Required) The Policy Definition Category.
  - `parameters` - (Optionnal) String JSON value of the policy parameters.
  - `non_compliance_message` - (Optionnal) A specific non compliance message for the policy


## Outputs

| Name | Description |
|------|-------------|

## References
Please check the following references for best practices.
* [Terraform Best Practices](https://www.terraform-best-practices.com/)
* [Azure Policy as Code with Terraform Part 1](https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1)