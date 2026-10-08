provider "azurerm" {
  resource_provider_registrations = "none"

  features {}
}

provider "airbyte" {
  server_url = var.airbyte_enabled ? "${local.airbyte_server_url}/api/public/v1" : ""

  client_id     = var.airbyte_enabled ? module.infrastructure_secrets[0].map.AIRBYTE-CLIENT-ID : ""
  client_secret = var.airbyte_enabled ? module.infrastructure_secrets[0].map.AIRBYTE-CLIENT-SECRET : ""
}

provider "google" {
  project = var.gcp_project_id
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = module.cluster_data.kubelogin_args
  }
}

provider "statuscake" {
  api_token = data.azurerm_key_vault_secret.statuscake_password.value
}
