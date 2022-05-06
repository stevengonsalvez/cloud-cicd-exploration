terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.24.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
}

provider "github" {
  owner = "action-foobar"
}

resource "github_repository_environment" "envs" {
  environment = var.environment_name
  repository  = var.github_repo_name
}


resource "github_actions_environment_secret" "sp_client_ids" {
  repository      = var.github_repo_name
  environment     = var.environment_name
  secret_name     = "SP_CLIENT_ID"
  plaintext_value = var.sp_client_id
  depends_on = [
    github_repository_environment.envs,
  ]
}

resource "github_actions_environment_secret" "sp_passwords" {
  repository      = var.github_repo_name
  environment     = var.environment_name
  secret_name     = "SP_PASSWORD"
  plaintext_value = var.sp_client_secret
  depends_on = [
    github_repository_environment.envs,
  ]
}

resource "github_actions_environment_secret" "subscription_ids" {
  repository      = var.github_repo_name
  environment     = var.environment_name
  secret_name     = "SUBSCRIPTION_ID"
  plaintext_value = var.subscription_id
  depends_on = [
    github_repository_environment.envs,
  ]
}