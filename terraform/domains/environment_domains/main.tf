module "domains" {
  source              = "./vendor/modules/domains//domains/environment_domains"
  zone                = var.zone
  front_door_name     = var.front_door_name
  resource_group_name = var.resource_group_name
  domains             = var.domains
  environment         = var.environment_short
  host_name           = var.origin_hostname
  null_host_header    = try(var.null_host_header, false)
  cached_paths        = try(var.cached_paths, [])
}

data "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
}

data "azurerm_dns_zone" "main" {
  name                = var.zone
  resource_group_name = var.resource_group_name
}

# Takes values from hosted_zone.domain_name.cnames (or txt_records, a-records). Use for domains which are not associated with front door.
module "dns_records" {
  source      = "./vendor/modules/domains//dns/records"
  hosted_zone = var.hosted_zone
}
