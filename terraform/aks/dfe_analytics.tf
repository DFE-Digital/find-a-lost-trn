module "dfe_analytics" {
  count  = var.enable_dfe_analytics_federated_auth ? 1 : 0
  source = "./vendor/modules/aks//aks/dfe_analytics"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = local.environment
  gcp_keyring           = local.gcp_keyring
  gcp_key               = local.gcp_key
  gcp_taxonomy_id       = local.gcp_taxonomy_id
  gcp_policy_tag_id     = local.gcp_policy_tag_id
}

locals {
  # Google Cloud values for the teaching-qualifications project, the same for
  # every environment. One hidden policy tag covers both the events table and
  # the Airbyte tables
  gcp_taxonomy_id   = "5159319666739647034"
  gcp_policy_tag_id = "2606812594222933114"
  gcp_keyring       = "faltrn-key-ring"
  gcp_key           = "faltrn-key"

  # BIGQUERY_PROJECT_ID, BIGQUERY_DATASET, BIGQUERY_TABLE_NAME and
  # GOOGLE_CLOUD_CREDENTIALS for the gem
  dfe_analytics_secret_variables = var.enable_dfe_analytics_federated_auth ? module.dfe_analytics[0].variables_map : {}
}
