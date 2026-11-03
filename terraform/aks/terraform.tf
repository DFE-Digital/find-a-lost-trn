terraform {
  required_version = "1.14.5"

  required_providers {
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "= 0.10.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.61.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "= 6.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.32.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "= 2.2.2"
    }
  }

  backend "azurerm" {
    container_name = "faltrn-tfstate"
  }
}
