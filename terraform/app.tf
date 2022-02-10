resource "cloudfoundry_route" "flt_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = var.flt_app_name
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_app" "app" {
  name         = var.flt_app_name
  space        = data.cloudfoundry_space.space.id
  instances    = var.flt_instances
  memory       = var.flt_memory
  disk_quota   = var.flt_disk_quota
  docker_image = var.flt_docker_image
  strategy     = "blue-green"

  routes {
    route = cloudfoundry_route.flt_public.id
  }
}
