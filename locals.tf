locals {
  ##########################################################################
  # 1. Global local parameters
  ##########################################################################
  naming               = replace(lower("${var.technical_zone}-${var.environment}-${var.application}"), " ", "")
  naming_noapplication = replace(lower("${var.technical_zone}-${var.environment}"), " ", "")

  template_folder = var.template_folder == null ? "." : var.template_folder
  nsg_files       = fileset(local.template_folder, "*.json")
  template_map = {
    for k, f in local.nsg_files : replace(k, ".json", "") => file("${local.template_folder}/${f}")
  }
}