terraform {
  required_version = "1.14.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
  }

  backend "azurerm" {
    container_name       = "faltrndomains-tf"
    resource_group_name  = "s189p01-faltrndomains-rg"
    storage_account_name = "s189p01faltrndomainstf"
    key                  = "faltrndomains.tfstate"
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}
