locals {
  ##########################################################################
  # 0. Global Configuration
  ##########################################################################
  naming               = replace(lower("${var.technical_zone}-${var.environment}-${var.application}"), " ", "")
  naming_noapplication = replace(lower("${var.technical_zone}-${var.environment}"), " ", "")

  ##########################################################################
  # 1. Virtual Network Configuration
  ##########################################################################

  reserved_subnets = [
    "GatewaySubnet",
    "AzureBastionSubnet",
    "AzureFirewallSubnet",
    "AzureFirewallManagementSubnet",
    "RouteServerSubnet"
  ]
  ##########################################################################
  # 2. Security Rules module
  ##########################################################################

  template_folder = var.template_folder == null ? "." : var.template_folder
  nsg_files       = fileset(local.template_folder, "*.json")
  template_map = {
    for k, f in local.nsg_files : replace(k, ".json", "") => file("${local.template_folder}/${f}")
  }
  ##########################################################################
  # 3. Diagnostic_settings
  ##########################################################################


}