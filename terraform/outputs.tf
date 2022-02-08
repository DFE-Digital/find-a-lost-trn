output "fmt_fqdn" {
  value = "${cloudfoundry_route.fmt_public.hostname}.${data.cloudfoundry_domain.cloudapps.name}"
}
