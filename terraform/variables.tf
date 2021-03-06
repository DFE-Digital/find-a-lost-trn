variable "environment_name" {
  type = string
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "key_vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "paas_api_url" {
  default = "https://api.london.cloud.service.gov.uk"
}

variable "paas_org_name" {
  type    = string
  default = "dfe"
}

variable "paas_space" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}
variable "flt_docker_image" {
  type = string
}

variable "flt_instances" {
  default = 1
}

variable "flt_memory" {
  default = "1024"
}

variable "flt_disk_quota" {
  default = "2048"
}

variable "logging_service_name" {
  type = string
}

variable "enable_external_logging" {
  type    = bool
  default = true
}

variable "hosting_environment_name" {
  type    = string
  default = ""
}

variable "postgres_database_service_plan" {
  type    = string
  default = "small-13"
}

variable "paas_restore_db_from_db_instance" {
  default = ""
}

variable "paas_restore_db_from_point_in_time_before" {
  default = ""
}

variable "redis_service_plan" {
  type    = string
  default = "tiny-6_x"
}

variable "statuscake_alerts" {
  type = map(any)
}

variable "hostnames" {
  default = []
  type    = list(any)
}

variable "prometheus_app" {
  default = null
}
locals {
  flt_app_name           = "find-a-lost-trn-${var.environment_name}${var.app_suffix}"
  postgres_database_name = "find-a-lost-trn-${var.environment_name}${var.app_suffix}-pg-svc"
  redis_name             = "find-a-lost-trn-${var.environment_name}${var.app_suffix}-redis-svc"
  app_cloudfoundry_service_instances = [
    cloudfoundry_service_instance.postgres.id,
    cloudfoundry_service_instance.redis.id,
  ]
  app_user_provided_service_bindings = var.enable_external_logging ? [cloudfoundry_user_provided_service.logging.id] : []
  app_service_bindings               = concat(local.app_cloudfoundry_service_instances, local.app_user_provided_service_bindings)
  flt_routes = flatten([
    cloudfoundry_route.flt_public,
    cloudfoundry_route.flt_internal,
    values(cloudfoundry_route.flt_education)
  ])
  restore_db_backup_params = var.paas_restore_db_from_db_instance != "" ? {
    restore_from_point_in_time_of     = var.paas_restore_db_from_db_instance
    restore_from_point_in_time_before = var.paas_restore_db_from_point_in_time_before
  } : {}

}
