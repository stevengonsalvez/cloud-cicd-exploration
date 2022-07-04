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

locals {
  subscriptions = toset(var.subscription_ids)
  owners        = toset(var.owners)
}

data "azurerm_subscription" "this" {
  for_each        = local.subscriptions
  subscription_id = each.key
}

data "azuread_user" "this" {
  for_each            = local.owners
  user_principal_name = each.key
}

locals {
  subscription_ids = [
    for sub in data.azurerm_subscription.this : sub.id
  ]
  owner_ids = [
    for owner in data.azuread_user.this : owner.id
  ]
  app_name = var.app_name

}

data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}


# Can use this only with roles below
# AppRoleAssignment.ReadWrite.All and Application.Read.All, or AppRoleAssignment.ReadWrite.All and Directory.Read.All, or Application.ReadWrite.All, or Directory.ReadWrite.All

# resource "azuread_service_principal" "msgraph" {
#   application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
#   use_existing   = true
# }



resource "azuread_application" "this" {
  display_name = local.app_name
  web {
    implicit_grant {
      access_token_issuance_enabled = true
    }
  }
  owners = local.owner_ids

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      # id   = azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
      # hardcoding as the above access to lookup does not exist - references can be found here: https://docs.microsoft.com/en-us/graph/permissions-reference
      id   = "18a4783c-866b-4cc7-a460-3d5e5662c884"
      type = "Role"
    }
    resource_access {
      # "User.Read.All"
      # hardcoding as the above access to lookup does not exist - references can be found here: https://docs.microsoft.com/en-us/graph/permissions-reference
      id   = "df021288-bdef-4463-88db-98f22de89214"
      type = "Role"
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this.application_id
  app_role_assignment_required = false
  owners                       = local.owner_ids
  lifecycle {
    prevent_destroy = false
  }
}

# Could expand this to an iterative input if need different roles on the subscription
resource "azurerm_role_assignment" "sub-contributor" {
  for_each             = toset(local.subscription_ids)
  scope                = each.key
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

resource "azuread_application_federated_identity_credential" "main" {
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-branch-main"
  description           = "deployments for repository cloud-cicd-exploration"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:stevengonsalvez/cloud-cicd-exploration:ref:refs/heads/main"
}

resource "azuread_application_federated_identity_credential" "pr" {
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-pr"
  description           = "deployments for repository cloud-cicd-exploration"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:stevengonsalvez/cloud-cicd-exploration:pull_request"
}

resource "azuread_application_federated_identity_credential" "env-prod" {
  for_each              = toset(var.environments)
  application_object_id = azuread_application.this.id
  display_name          = "az-oidc-env-${each.key}"
  description           = "deployments for repository cloud-cicd-exploration"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:stevengonsalvez/cloud-cicd-exploration::environment:${each.key}"
}

