terraform {
  required_version = "= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "s189p01-faltrndomains-rg"
    storage_account_name = "s189p01faltrndomainstf"
    container_name       = "faltrndomains-tf"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}
