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
    shortname               = string
    cidr                    = string
    enforce_private_link_service_network_policies     = bool
    enforce_private_link_endpoint_network_policies = bool
  }))
}