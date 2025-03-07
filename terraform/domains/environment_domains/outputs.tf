output "external_urls" {
  value = flatten([
    for domain in var.domains : (domain == "apex" ?
      "https://${local.zone}" :
      "https://${domain}.${local.zone}"
    )
    ]
  )
}
