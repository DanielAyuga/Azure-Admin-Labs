#Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_machine_extension" "ama" {
  name                 = "${var.vm_name}-ama"
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.0"

  settings = <<SETTINGS
  {
    "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
  }
SETTINGS

  protected_settings = <<PROTECTED
  {
    "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
  }
PROTECTED
}


#Data Rule Collection (DCR)
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = var.dcr_name
  location            = var.location
  resource_group_name = var.rg_name

  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "lawdest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Event"]
    destinations = ["lawdest"]
  }

  data_sources {
    performance_counter {
      name        = "perfCounters"
      streams     = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space",
      ]
    }

    windows_event_log {
      name    = "eventLogs"
      streams = ["Microsoft-Event"]

      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2)]]",
        "System!*[System[(Level=1 or Level=2)]]",
        "Security!*[System[(EventID=4625)]]",
        "Security!*[System[(EventID=4624)]]",
      ]
    }
  }
}

#Añadimos un Data Collection Endpoint
resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "${var.vm_name}-dce"
  location            = var.location
  resource_group_name = var.rg_name
}

#Asociación DCR -> VM
resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = "${var.vm_name}-dcr-assoc"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
}

#Creación del Workbook
resource "azurerm_application_insights_workbook" "vm_workbook" {
  name                = uuid()
  resource_group_name = var.rg_name
  location            = var.location
  display_name        = "var.vm_workbook_name"
  category            = "workbook"

  data_json = templatefile("${path.module}/workbook.json", {
    law_id = azurerm_log_analytics_workspace.law.id
  })
}

#Action Group
resource "azurerm_monitor_action_group" "ag" {
  name                = var.action_group_name
  resource_group_name = var.rg_name
  short_name          = "alerts"

  email_receiver {
    name                    = "emailReceiver"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

#Alerta CPU>80%
resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "${var.vm_name}-cpu-high"
  resource_group_name = var.rg_name
  scopes              = [var.vm_id]
  description         = "CPU usage above 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

#Alerta 5 inicios de sesión fallidos
resource "azurerm_monitor_scheduled_query_rules_alert" "failed_logins" {
  name                = "${var.vm_name}-failed-logins"
  resource_group_name = var.rg_name
  location            = var.location
  description         = "Detects 5 failed login attempts in 5 minutes"
  severity            = 2
  enabled             = true

  frequency   = 5
  time_window = 5

  query = <<-EOF
  Event
  | where TimeGenerated > ago(5m)
  | where EventID == 4625
  | summarize fails = count() by Computer
  | where fails >= 5
  EOF

  data_source_id = azurerm_log_analytics_workspace.law.id

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [azurerm_monitor_action_group.ag.id]
  }
}

#Alerta Power State
resource "azurerm_monitor_scheduled_query_rules_alert" "vm_powerstate" {
  name                = "${var.vm_name}-powerstate"
  resource_group_name = var.rg_name
  location            = var.location
  description         = "Detecta si la VM deja de enviar Heartbeat"
  severity            = 2
  enabled             = true

  frequency   = 5
  time_window = 5

  query = <<-EOF
  Heartbeat
  | summarize LastSeen = max(TimeGenerated)
  | extend MinutesSince = datetime_diff('minute', now(), LastSeen)
  | where MinutesSince > 5
  EOF

  data_source_id = azurerm_log_analytics_workspace.law.id

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [azurerm_monitor_action_group.ag.id]
  }
}
