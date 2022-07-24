locals {
  ##########################################################################
  # 1. Global local parameters
  ##########################################################################
  naming = replace(lower("${var.technical_zone}-${var.environment}-${var.application}"), " ", "")


}