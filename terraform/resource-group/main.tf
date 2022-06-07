terraform {
  # to ignore backend for these tests
  backend "local" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.9.0"
    }
  }
}

provider "azurerm" {
  # use_oidc = true
  features {}
}


locals {
  created          = time_static.activation_date.unix
  created_readable = formatdate("YYYY-MM-DD_hh-mm-ss", time_static.activation_date.rfc3339)
}

resource "time_static" "activation_date" {}

resource "azurerm_resource_group" "example" {
  name     = "sandbox-rg-test"
  location = "North Europe"
  tags = {
    ttl                    = "2h"
    creation_time          = local.created
    creation_time_readable = local.created_readable
    delete_marker          = "true"
  }
}
