output "law_id" {
  value = azurerm_log_analytics_workspace.law.id
}

output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.dcr.id
}
