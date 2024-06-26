variable "app_environment" {
  type        = string
  description = "Environment name in full e.g development"
}

variable "app_key_vault" {
  default     = null
  description = "app kv name"
}

variable "file_environment" {
  type        = string
  description = "AKS environment name e.g dev"
}

variable "app_suffix" {
  type        = string
  default     = ""
  description = "App suffix"
}

variable "azure_resource_prefix" {
  type        = string
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}

variable "cluster" {
  type        = string
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}

variable "config_short" {
  type        = string
  description = "Short name of the environment configuration, e.g. dv, pp, pd..."
}

variable "deploy_azure_backing_services" {
  type        = string
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}

variable "enable_logit" { default = false }

variable "enable_monitoring" {
  type        = bool
  default     = false
  description = "Enable monitoring and alerting"
}
variable "postgres_enable_high_availability" {
  default = false
}
variable "postgres_flexible_server_sku" {
  default = "B_Standard_B1ms"
}
variable "azure_maintenance_window" {
  default = null
}

variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}

variable "namespace" {
  type        = string
  description = "AKS namespace where this app is deployed"
}

variable "service_short" {
  type        = string
  description = "Short name to identify the service. Up to 6 charcters."
}

variable "replicas" {
  default = 1
  type    = number
}

variable "memory_max" {
  default     = "1Gi"
  type        = string
  description = "Max memory size"
}

variable "worker_replicas" {
  default = 1
  type    = number
}

variable "worker_memory_max" {
  default     = "1Gi"
  type        = string
  description = "Max memory size of worker"
}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

variable "app_docker_image" {
  description = "image name and version "
}

variable "deploy_redis" {
  default     = true
  description = "whether Deploy redis or not"
}

variable "deploy_postgres" {
  default     = true
  description = "whether Deploy postgres or not"
}

variable "key_vault_name" {
  default     = null
  description = "the name of the key vault to get postgres and redis"
}

variable "key_vault_resource_group" {
  default     = null
  description = "the name of the key vault resorce group"
}

variable "inf_vault_name" {
  default     = null
  description = "infrastructure kv name"
}

variable "azure_enable_backup_storage" {
  default = false
}

variable "review_url_db_name" {
  default     = null
  description = "the name of the secret storing review db url"
}

variable "review_url_redis_name" {
  default     = null
  description = "the name of the secret storing review redis url"
}

# StatusCake variables
variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

variable "api_token" { default = "" }
