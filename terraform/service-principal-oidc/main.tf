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


data "azurerm_subscription" "this" {
}

locals {
  scope    = data.azurerm_subscription.this.id
  app_name = "tf-oidc-test-sample"
}

data "azuread_client_config" "current" {}

data "azuread_user" "this" {
  user_principal_name = var.owner
}

resource "azuread_application" "this" {
  display_name = local.app_name
  web {
    implicit_grant {
      access_token_issuance_enabled = true
    }
  }
  owners = [data.azuread_client_config.current.object_id, data.azuread_user.this.object_id]
  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this.application_id
  app_role_assignment_required = false
  lifecycle {
    prevent_destroy = false
  }
}

resource "azuread_application_password" "this" {
  application_object_id = azuread_application.this.id
  display_name          = "tf-credentials"
  end_date              = "2099-01-01T01:02:03Z"
}


resource "azurerm_role_assignment" "sub-contributor" {
  scope                = local.scope
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.this.id
  // If new SP there  may be replciation lag this disables validation
  skip_service_principal_aad_check = true
  lifecycle {
    ignore_changes = [
      scope,
    ]
  }
}

resource "azuread_application_federated_identity_credential" "example" {
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-test"
  description           = "deployments for repository cloud-cicd-exploration"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:stevengonsalvez/cloud-cicd-exploration:ref:refs/heads/main"
}