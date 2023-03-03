terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.9.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.22.0"
    }
  }
}



provider "azurerm" {
  features {}
}

variable "repository_name" {
  type        = string
  description = "only the name of the repository under stevengonsavez , eg: cloud-cicd-exploration"
}

variable "application_object_id" {
  type        = string
  description = "The object id of the application"
}


locals {
  t = ["Nonprod", "deveun", "deveuw"]
}

resource "azuread_application_federated_identity_credential" "main" {
  count                 = length(local.t)
  application_object_id = var.application_object_id
  display_name          = "az-oidc-branch-${local.t[count.index]}"
  description           = "OIDC access for ${var.repository_name} branch ${local.t[count.index]}"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:stevengonsalvez/${var.repository_name}:environment:${local.t[count.index]}"
}