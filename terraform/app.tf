resource "cloudfoundry_route" "fmt_public" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = var.fmt_app_name
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_app" "api" {
  name                       = var.fmt_app_name
  space                      = data.cloudfoundry_space.space.id
  instances                  = var.fmt_instances
  memory                     = var.fmt_memory
  disk_quota                 = var.fmt_disk_quota
  docker_image               = var.fmt_docker_image
  strategy                   = "blue-green"
  health_check_type          = "http"
  health_check_http_endpoint = "/"

  routes {
    route = cloudfoundry_route.fmt_public.id
  }
}
