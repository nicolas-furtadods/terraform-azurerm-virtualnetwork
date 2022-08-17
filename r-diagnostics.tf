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
