module "dfe_analytics" {
  count  = var.enable_dfe_analytics_federated_auth ? 1 : 0
  source = "./vendor/modules/aks//aks/dfe_analytics"

  azure_resource_prefix = var.azure_resource_prefix
  cluster               = var.cluster
  namespace             = var.namespace
  service_short         = var.service_short
  environment           = local.environment
  gcp_keyring           = var.gcp_keyring
  gcp_key               = var.gcp_key
  gcp_taxonomy_id       = var.gcp_taxonomy_id
  gcp_policy_tag_id     = var.gcp_policy_tag_id
}

locals {
  # BIGQUERY_PROJECT_ID, BIGQUERY_DATASET, BIGQUERY_TABLE_NAME and
  # GOOGLE_CLOUD_CREDENTIALS for the gem
  dfe_analytics_secret_variables = var.enable_dfe_analytics_federated_auth ? module.dfe_analytics[0].variables_map : {}
}
