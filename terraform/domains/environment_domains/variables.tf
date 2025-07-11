variable "front_door_name" {
  type        = string
  description = "Name of Azure Front Door"
  default     = "s189p01-faltrndomains-fd"
}

variable "resource_group_name" {
  type        = string
  description = "Name of resouce group name"
  default     = "s189p01-faltrndomains-rg"
}

variable "domains" {
  description = "List of domains record names"
}

variable "environment_tag" {
  type        = string
  description = "Environment"
}

variable "environment_short" {
  type        = string
  description = "Short name for environment"
}

variable "origin_hostname" {
  type        = string
  description = "Origin endpoint url"
}

locals {
  zone     = "find-a-lost-trn.education.gov.uk"
  hostname = "${var.domains[0]}.${local.zone}"
}

variable "null_host_header" {
  default     = false
  description = "The origin_host_header for the azurerm_cdn_frontdoor_origin resource will be var.host_name (if false) or null (if true). If null then the host name from the incoming request will be used."
}

variable "cached_paths" {
  type        = list(string)
  default     = []
  description = "List of path patterns such as /assets/* that front door will cache"
}

variable "rate_limit" {
  type = list(object({
    agent        = optional(string)
    priority     = optional(number)
    duration     = optional(number)
    limit        = optional(number)
    selector     = optional(string)
    operator     = optional(string)
    match_values = optional(string)
  }))
  default = null
}

variable "rate_limit_max" {
  type    = string
  default = null
}
