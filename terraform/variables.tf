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

variable "flt_app_name" {
  type = string
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

variable "postgres_database_name" {
  type = string
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
variable "redis_name" {
  type = string
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
