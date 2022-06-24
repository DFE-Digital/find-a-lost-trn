locals {
  app_environment_variables = merge(try(local.infrastructure_secrets, null),
    {
      REDIS_URL = cloudfoundry_service_key.redis_key.credentials.uri
    }
  )
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

resource "cloudfoundry_app" "worker" {
  name         = "${var.flt_app_name}-worker"
  space        = data.cloudfoundry_space.space.id
  instances    = var.flt_instances
  memory       = var.flt_memory
  disk_quota   = var.flt_disk_quota
  docker_image = var.flt_docker_image
  command      = "bundle exec sidekiq -C ./config/sidekiq.yml"
  strategy     = "blue-green"
  environment  = local.app_environment_variables

  health_check_type = "process"

  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }

  service_binding {
    service_instance = cloudfoundry_service_instance.redis.id
  }
}
