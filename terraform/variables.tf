variable "environment_name" {
  type = string
}

variable "azure_sp_credentials_json" {
  type = string
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
  default = "1024"
}

variable "postgres_database_name" {
  type = string
}

variable "postgres_database_service_plan" {
  type    = string
  default = "small-13"
}

locals {
  flt_routes = flatten([
    cloudfoundry_route.flt_public,
    values(cloudfoundry_route.flt_internal)
  ])
}
