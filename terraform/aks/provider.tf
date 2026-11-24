provider "azurerm" {
  resource_provider_registrations = "none"

  features {}
}

provider "airbyte" {
  server_url = "${local.airbyte_server_url}/api/public/v1"

  # try() so the provider still has credentials while Airbyte resources are
  # being destroyed, and "" where the infra Key Vault has no Airbyte secrets
  client_id     = try(module.infrastructure_secrets.map.AIRBYTE-CLIENT-ID, "")
  client_secret = try(module.infrastructure_secrets.map.AIRBYTE-CLIENT-SECRET, "")
}

provider "google" {
  project = "teaching-qualifications"
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
