module "statuscake" {
  for_each = var.statuscake_alerts

  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls    = each.value.website_url
  contact_groups = each.value.contact_group

  confirmation = try(each.value.confirmations, 2)
  content_matchers  = try(each.value.content_matchers, [])
}

resource "statuscake_ssl_check" "domain-alert" {
  for_each = { for k, v in var.statuscake_alerts : k => v if can(v.ssl_domain) }

  check_interval   = 3600 # Check once per hour
  contact_groups   = each.value.contact_group
  follow_redirects = true

  alert_config {
    alert_at = [3, 7, 30] # Alert 1 month, 1 week then 3 days before expiration

    on_reminder = true
    on_expiry   = true
    on_broken   = true
    on_mixed    = true
  }

  monitored_resource {
    address = each.value.ssl_domain
  }
}
