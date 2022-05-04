locals {
  app_environment_variables = {
    DQT_API_KEY              = local.infrastructure_secrets.DQT_API_KEY,
    DQT_API_URL              = local.infrastructure_secrets.DQT_API_URL,
    GOVUK_NOTIFY_API_KEY     = local.infrastructure_secrets.GOVUK_NOTIFY_API_KEY,
    HOSTING_ENVIRONMENT_NAME = local.infrastructure_secrets.HOSTING_ENVIRONMENT_NAME,
    REDIS_URL                = cloudfoundry_service_key.redis_key.credentials.uri,
    SECRET_KEY_BASE          = local.infrastructure_secrets.SECRET_KEY_BASE,
    SENTRY_DSN               = local.infrastructure_secrets.SENTRY_DSN,
    SUPPORT_PASSWORD         = local.infrastructure_secrets.SUPPORT_PASSWORD,
    SUPPORT_USERNAME         = local.infrastructure_secrets.SUPPORT_USERNAME,
    ZENDESK_TOKEN            = local.infrastructure_secrets.ZENDESK_TOKEN,
    ZENDESK_USER             = local.infrastructure_secrets.ZENDESK_USER,
  }
  logstash_endpoint = data.azurerm_key_vault_secret.secrets["LOGSTASH-ENDPOINT"].value
}
resource "cloudfoundry_route" "flt_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = var.flt_app_name
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "flt_internal" {
  count    = local.configure_prometheus_network_policy
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.flt_app_name
}

resource "cloudfoundry_route" "flt_education" {
  for_each = toset(var.hostnames)
  domain   = data.cloudfoundry_domain.education_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource "cloudfoundry_user_provided_service" "logging" {
  name             = var.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = "syslog-tls://${local.logstash_endpoint}"
}
resource "cloudfoundry_service_instance" "postgres" {
  name         = var.postgres_database_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_database_service_plan]
  json_params  = jsonencode(local.restore_db_backup_params)
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "cloudfoundry_service_instance" "redis" {
  name         = var.redis_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_service_plan]
}

resource "cloudfoundry_service_key" "redis_key" {
  name             = "${var.redis_name}_key"
  service_instance = cloudfoundry_service_instance.redis.id
}
resource "cloudfoundry_app" "app" {
  name                       = var.flt_app_name
  space                      = data.cloudfoundry_space.space.id
  instances                  = var.flt_instances
  memory                     = var.flt_memory
  disk_quota                 = var.flt_disk_quota
  docker_image               = var.flt_docker_image
  strategy                   = "blue-green"
  environment                = local.app_environment_variables
  health_check_type          = "http"
  health_check_http_endpoint = "/health"
  dynamic "routes" {
    for_each = local.flt_routes
    content {
      route = routes.value.id
    }
  }

  service_binding {
    service_instance = cloudfoundry_user_provided_service.logging.id
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }

}
