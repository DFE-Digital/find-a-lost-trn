module "infrastructure_secrets" {
  count  = var.airbyte_enabled ? 1 : 0
  source = "./vendor/modules/aks//aks/secrets"

  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  key_vault_short       = "inf"
}

module "airbyte" {
  count  = var.airbyte_enabled ? 1 : 0
  source = "./vendor/modules/aks//aks/airbyte"

  environment           = local.airbyte_environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  service_name          = local.service_name
  docker_image          = var.app_docker_image
  postgres_version      = local.postgres_server_version
  postgres_url          = module.postgres.url

  host_name     = module.postgres.host
  database_name = module.postgres.name
  workspace_id  = module.infrastructure_secrets[0].map.AIRBYTE-WORKSPACE-ID
  client_id     = module.infrastructure_secrets[0].map.AIRBYTE-CLIENT-ID
  client_secret = module.infrastructure_secrets[0].map.AIRBYTE-CLIENT-SECRET

  server_url        = local.airbyte_server_url
  connection_status = var.airbyte_connection_status

  cluster           = var.cluster
  namespace         = var.namespace
  gcp_taxonomy_id   = var.gcp_taxonomy_id
  gcp_policy_tag_id = var.gcp_airbyte_policy_tag_id
  gcp_keyring       = var.gcp_keyring
  gcp_key           = var.gcp_key
  gcp_bq_sa         = local.app_service_account

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  use_azure = var.deploy_azure_backing_services
}

locals {
  # Some of the module's resource names have length limits that a full
  # environment name like "preproduction" breaks
  airbyte_environment = coalesce(var.airbyte_environment, local.environment)
  airbyte_server_url  = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"

  # The dfe_analytics module creates this account. The airbyte module makes it
  # an owner of the Airbyte dataset, so the worker can tag the hidden columns
  app_service_account = "app-wif-${var.service_short}-${local.environment}"

  # Must match the dataset name the airbyte module builds
  airbyte_dataset = replace("${var.service_short}_airbyte_${local.airbyte_environment}", "-", "_")

  # With airbyte_enabled set in the initializer, the gem won't build a
  # BigQuery client for request events without the Airbyte dataset name
  airbyte_dataset_variables = var.enable_dfe_analytics_federated_auth ? {
    BIGQUERY_AIRBYTE_DATASET = local.airbyte_dataset
  } : {}

  # The deploy job queues a worker job that reads these to refresh the
  # connection, run a sync and tag the hidden columns
  airbyte_config_variables = var.airbyte_enabled ? {
    AIRBYTE_SERVER_URL         = local.airbyte_server_url
    BIGQUERY_HIDDEN_POLICY_TAG = "projects/${var.gcp_project_id}/locations/europe-west2/taxonomies/${var.gcp_taxonomy_id}/policyTags/${var.gcp_airbyte_policy_tag_id}"
  } : {}

  airbyte_secret_variables = var.airbyte_enabled ? {
    AIRBYTE_CLIENT_ID     = module.infrastructure_secrets[0].map.AIRBYTE-CLIENT-ID
    AIRBYTE_CLIENT_SECRET = module.infrastructure_secrets[0].map.AIRBYTE-CLIENT-SECRET
    AIRBYTE_CONFIGURATION = jsonencode({
      SOURCE_ID      = module.airbyte[0].airbyte_source_id
      DESTINATION_ID = module.airbyte[0].airbyte_destination_id
      CONNECTION_ID  = module.airbyte[0].airbyte_connection_id
    })
  } : {}
}
