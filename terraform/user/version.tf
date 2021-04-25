terraform {
  required_version = "~>0.14"
  required_providers {
    # integrations/github
    # https://registry.terraform.io/providers/integrations/github/latest/docs
    github = {
      source  = "integrations/github"
      version = "=4.5.0"
    }
  }
}