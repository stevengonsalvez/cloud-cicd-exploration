terraform {
  backend "local" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.7.0"
    }
  }
}

provider "azurerm" {
  features {}
}

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
}