resource "shoreline_notebook" "airbyte_connection_issues" {
  name       = "airbyte_connection_issues"
  data       = file("${path.module}/data/airbyte_connection_issues.json")
  depends_on = [shoreline_action.invoke_check_airbyte_pod_connectivity,shoreline_action.invoke_rolling_restart]
}

resource "shoreline_file" "check_airbyte_pod_connectivity" {
  name             = "check_airbyte_pod_connectivity"
  input_file       = "${path.module}/data/check_airbyte_pod_connectivity.sh"
  md5              = filemd5("${path.module}/data/check_airbyte_pod_connectivity.sh")
  description      = "Network connectivity issues: Airbyte requires a stable internet connection to establish and maintain connections with the data sources and destinations. Any disruptions in the network can cause connection issues, leading to incidents of this type."
  destination_path = "/tmp/check_airbyte_pod_connectivity.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "rolling_restart" {
  name             = "rolling_restart"
  input_file       = "${path.module}/data/rolling_restart.sh"
  md5              = filemd5("${path.module}/data/rolling_restart.sh")
  description      = "Restart services: Restart any relevant services that are involved in the Airbyte connection such as the web server or the database server. This can help reset the connection and resolve any temporary issues."
  destination_path = "/tmp/rolling_restart.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_airbyte_pod_connectivity" {
  name        = "invoke_check_airbyte_pod_connectivity"
  description = "Network connectivity issues: Airbyte requires a stable internet connection to establish and maintain connections with the data sources and destinations. Any disruptions in the network can cause connection issues, leading to incidents of this type."
  command     = "`chmod +x /tmp/check_airbyte_pod_connectivity.sh && /tmp/check_airbyte_pod_connectivity.sh`"
  params      = ["NAMESPACE","AIRBYTE_DEPLOYMENT_NAME"]
  file_deps   = ["check_airbyte_pod_connectivity"]
  enabled     = true
  depends_on  = [shoreline_file.check_airbyte_pod_connectivity]
}

resource "shoreline_action" "invoke_rolling_restart" {
  name        = "invoke_rolling_restart"
  description = "Restart services: Restart any relevant services that are involved in the Airbyte connection such as the web server or the database server. This can help reset the connection and resolve any temporary issues."
  command     = "`chmod +x /tmp/rolling_restart.sh && /tmp/rolling_restart.sh`"
  params      = ["NAMESPACE","AIRBYTE_DEPLOYMENT_NAME"]
  file_deps   = ["rolling_restart"]
  enabled     = true
  depends_on  = [shoreline_file.rolling_restart]
}

