resource "random_string" "storage_name" {
  length  = 19
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "azurerm_storage_account" "this" {
  #checkov:skip=CKV_AZURE_43: "Ensure Storage Accounts adhere to the naming rules"
  #checkov:skip=CKV_AZURE_35: "Ensure default network access rule for Storage Accounts is set to deny"
  #checkov:skip=CKV2_AZURE_1: "Ensure storage for critical data are encrypted with Customer Managed Key"
  #checkov:skip=CKV2_AZURE_18: "Ensure that Storage Accounts use customer-managed key for encryption"
  #checkov:skip=CKV2_AZURE_8: "Ensure the storage container storing the activity logs is not publicly accessible"
  name                      = "state${random_string.storage_name.result}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = var.storage_config.account_kind
  account_tier              = element(split("_", var.storage_config.storage_type), 0)
  access_tier               = var.storage_config.access_tier
  account_replication_type  = element(split("_", var.storage_config.storage_type), 1)
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.tags

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_encryption_scope" "this" {
  name               = "MicrosoftManaged" # Changing this forces a new Storage Encryption Scope to be created
  storage_account_id = azurerm_storage_account.this.id
  source             = "Microsoft.Storage"
}


resource "azurerm_storage_container" "containers" {
  #checkov:skip=CKV2_AZURE_21: "Ensure Storage logging is enabled for Blob service for read requests"
  count                 = length(var.containers)
  name                  = var.containers[count.index]
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
