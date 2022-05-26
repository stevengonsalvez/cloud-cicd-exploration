terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.7.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.45.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  owner = "action-foobar"
}

data "azurerm_client_config" "current" {}

module "regions" {
  source       = "claranet/regions/azurerm"
  version      = "5.1.0"
  azure_region = var.azure_region
}

locals {
  tags = merge(var.additional_tags, var.dynamic_tags, {
    foo      = var.app_name
    location = module.regions.location_short
  })
  resource_name_prefix = "${substr(var.app_name, 0, 16)}-${module.regions.location_short}-layer1"
  resource_group_name  = "${local.resource_name_prefix}-rg"
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = module.regions.location_cli
  tags = merge(local.tags, {
    "Name" = local.resource_group_name
  })
  lifecycle {
    prevent_destroy = true
  }
}

module "azure_storage" {
  source              = "../modules/azure-storage"
  subscription_id     = data.azurerm_client_config.current.subscription_id
  resource_group_name = azurerm_resource_group.this.name
  location            = module.regions.location_cli
  storage_config      = var.storage_config
  containers          = concat(["shared"], var.containers)
  tags                = local.tags
}

resource "github_actions_secret" "connection_string" {
  repository = var.github_repo_name
  #checkov:skip=CKV_GIT_4: "Ensure Secrets are encrypted"
  secret_name     = "${var.environment_name}_SHARED_BACKEND_CONFIG"
  plaintext_value = "resource_group_name=${local.resource_group_name},container_name=shared,storage_account_name=${module.azure_storage.storage_account_name}"
}

resource "github_repository_environment" "envs" {
  count       = length(local.environment_names)
  environment = local.environment_names[count.index]
  repository  = var.github_repo_name
}

resource "github_actions_environment_secret" "subscription_backend_config" {
  repository  = var.github_repo_name
  environment = var.environment_name
  #checkov:skip=CKV_GIT_4: "Ensure Secrets are encrypted"
  secret_name     = "BACKEND_CONFIG" # pragma: allowlist secret
  plaintext_value = "resource_group_name=${local.resource_group_name},container_name=shared,storage_account_name=${module.azure_storage.storage_account_name}"
  depends_on = [
    github_repository_environment.envs,
  ]
}

resource "github_actions_environment_secret" "backend_configs" {
  count       = length(local.environment_names)
  repository  = var.github_repo_name
  environment = local.environment_names[count.index]
  #checkov:skip=CKV_SECRET_6 "Base64 High Entropy String"  # pragma: allowlist secret
  #checkov:skip=CKV_GIT_4: "Ensure Secrets are encrypted"
  secret_name     = "BACKEND_CONFIG" # pragma: allowlist secret
  plaintext_value = "resource_group_name=${local.resource_group_name},container_name=${var.containers[count.index]},storage_account_name=${module.azure_storage.storage_account_name}"
  depends_on = [
    github_repository_environment.envs,
  ]
}

resource "github_actions_environment_secret" "sp_client_ids" {
  count       = length(local.environment_names)
  repository  = var.github_repo_name
  environment = local.environment_names[count.index]
  #checkov:skip=CKV_SECRET_6: "Base64 High Entropy String"  # pragma: allowlist secret
  secret_name     = "SP_CLIENT_ID" # pragma: allowlist secret
  plaintext_value = var.sp_client_id
  depends_on = [
    github_repository_environment.envs,
  ]
}

resource "github_actions_environment_secret" "sp_passwords" {
  count           = length(local.environment_names)
  repository      = var.github_repo_name
  environment     = local.environment_names[count.index]
  secret_name     = "SP_PASSWORD" # pragma: allowlist secret
  plaintext_value = var.sp_client_secret
  depends_on = [
    github_repository_environment.envs,
  ]
}

resource "github_actions_environment_secret" "subscription_ids" {
  count       = length(local.environment_names)
  repository  = var.github_repo_name
  environment = local.environment_names[count.index]
  #checkov:skip=CKV_SECRET_6: "Base64 High Entropy String"  # pragma: allowlist secret
  secret_name     = "SUBSCRIPTION_ID" # pragma: allowlist secret
  plaintext_value = data.azurerm_client_config.current.subscription_id
  depends_on = [
    github_repository_environment.envs,
  ]
}
