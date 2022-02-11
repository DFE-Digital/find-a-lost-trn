resource "cloudfoundry_route" "flt_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = var.flt_app_name
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "flt_internal" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.flt_app_name
}
resource "cloudfoundry_service_instance" "postgres" {
  name         = var.postgres_database_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_database_service_plan]
}


resource "cloudfoundry_app" "app" {
  name         = var.flt_app_name
  space        = data.cloudfoundry_space.space.id
  instances    = var.flt_instances
  memory       = var.flt_memory
  disk_quota   = var.flt_disk_quota
  docker_image = var.flt_docker_image
  strategy     = "blue-green"

  dynamic "routes" {
    for_each = local.flt_routes
    content {
      route = routes.value.id
    }
  }
  service_binding {
    service_instance = cloudfoundry_service_instance.postgres.id
  }
}
