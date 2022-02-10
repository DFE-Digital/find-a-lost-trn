output "flt_fqdn" {
  value = "${cloudfoundry_route.flt_public.hostname}.${data.cloudfoundry_domain.cloudapps.name}"
}
