module "domains" {
  source              = "./vendor/modules/domains//domains/environment_domains"
  zone                = local.zone
  front_door_name     = var.front_door_name
  resource_group_name = var.resource_group_name
  domains             = var.domains
  environment         = var.environment_short
  host_name           = var.origin_hostname
  null_host_header    = try(var.null_host_header, false)
  cached_paths        = try(var.cached_paths, [])
  rate_limit          = try(var.rate_limit, null)
  rate_limit_max      = try(var.rate_limit_max, null)
}
