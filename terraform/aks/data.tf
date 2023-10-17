data "azurerm_key_vault" "infra_secret_vault" {
  name                = var.inf_vault_name
  resource_group_name = var.key_vault_resource_group
}

data "azurerm_key_vault_secret" "statuscake_password" {
  name         = "STATUSCAKE-PASSWORD"
  key_vault_id = data.azurerm_key_vault.infra_secret_vault.id
}