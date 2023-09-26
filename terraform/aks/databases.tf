module "postgres" {
  source                    = "./vendor/modules/aks//aks/postgres"

  namespace                 = var.namespace
  environment               = local.environment
  azure_resource_prefix     = var.azure_resource_prefix
  service_name              = local.service_name
  service_short             = var.service_short
  config_short              = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure                 = var.deploy_azure_backing_services
  azure_enable_monitoring   = var.enable_monitoring
  azure_extensions          = ["plpgsql", "citext", "uuid-ossp"]
  server_version            = "14"
}

module "redis" {
  count                     = var.deploy_redis ? 1 : 0
  source                    = "./vendor/modules/aks//aks/redis"

  namespace                 = var.namespace
  environment               = local.environment
  azure_resource_prefix     = var.azure_resource_prefix
  service_name              = local.service_name
  service_short             = var.service_short
  config_short              = var.config_short

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure                 = var.deploy_azure_backing_services
  azure_enable_monitoring   = var.enable_monitoring
  azure_patch_schedule      = [{ "day_of_week" : "Sunday", "start_hour_utc" : 01 }]
}
