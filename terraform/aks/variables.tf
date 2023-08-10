variable "app_environment" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
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
