terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.15.0"
    }
  }
}

provider "azurerm" {
  alias = "diagnostics"
  features {}
  subscription_id = var.diagnostic_settings != null ? var.diagnostic_settings.subscription_id : var.subscription_id
}
