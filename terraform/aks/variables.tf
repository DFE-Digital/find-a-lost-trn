variable "app_environment" {
  type = string
  description = "Environment name in full e.g development"
}

variable "file_environment" {
  type = string
  description = "AKS environment name e.g dev"
}

variable "app_suffix" {
  type    = string
  default = ""
  description = "App suffix"
}

variable "azure_resource_prefix" {
  type = string
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "cluster" {
  type = string
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}

variable "config_short" {
  type = string
  description = "Short name of the environment configuration, e.g. dv, pp, pd..."
}

variable "deploy_azure_backing_services" {
  type    = string
  default = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}

variable "enable_monitoring" {
  type    = bool
  default = true
  description = "Enable monitoring and alerting"
}

variable "namespace" {
  type = string
  description = "AKS namespace where this app is deployed"
}

variable "service_short" {
  type = string
  description = "Short name to identify the service. Up to 6 charcters."
}

variable "replicas" { 
  default = 1 
  type = number
}

variable "memory_max" { 
  default = "1Gi" 
  type = string
  description = "Max memory size"
}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

# PaaS variables
variable "paas_app_docker_image" {
  description = "PaaS image name and version "
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

variable "review_url_db_name" {
  default     = null
  description = "the name of the secret storing review db url"
}

variable "review_url_redis_name" {
    default     = null
  description = "the name of the secret storing review redis url"
}
