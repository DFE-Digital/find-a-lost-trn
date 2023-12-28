locals {
  environment  = "${var.app_environment}${var.app_suffix}"
  service_name = "find-a-lost-trn"
  app_secrets = {
    DATABASE_URL = var.deploy_postgres ? module.postgres.url : ""
    REDIS_URL    = var.deploy_redis ? module.redis[0].url : ""
  }
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = local.environment
  service_name = local.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image           = var.paas_app_docker_image
  max_memory             = var.memory_max
  replicas               = var.replicas
  web_external_hostnames = var.gov_uk_host_names
  web_port               = 3000
  probe_path             = "/health"
}

module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace              = var.namespace
  environment            = local.environment
  azure_resource_prefix  = var.azure_resource_prefix
  service_short          = var.service_short
  config_short           = var.config_short
  config_variables       = { AKS_ENV_NAME = var.file_environment, EnableMetrics = false }
  secret_variables       = local.app_secrets
  secret_key_vault_short = "app"
}

module "worker_application" {
  source                     = "./vendor/modules/aks//aks/application"
  name                       = "worker"
  is_web                     = false
  namespace                  = var.namespace
  environment                = local.environment
  service_name               = local.service_name
  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  docker_image               = var.paas_app_docker_image
  command                    = ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml"]
  probe_command              = ["pgrep", "-f", "sidekiq"]
  max_memory                 = var.worker_memory_max
  replicas                   = var.worker_replicas
}
