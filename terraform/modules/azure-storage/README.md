## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| subscription_service_principal | ../azure-service-principal |  |

## Resources

| Name |
|------|
| [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) |
| [azurerm_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| containers | Name of the containers (1 per environment in a subscription e.g  dev,test,stage in non prod and prod-neu, prod-weu in production) | `list(string)` | n/a | yes |
| location | Azure region where resources will be created | `any` | n/a | yes |
| resource\_group\_name | Name of the resource group to create or use | `any` | n/a | yes |
| storage\_config | The azure storage configuration | <pre>object({<br>    storage_type = string<br>    account_kind = string<br>    access_tier  = string<br>  })</pre> | n/a | yes |
| subscription\_id | The subscription id to use | `any` | n/a | yes |
| tags | n/a | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| containers | The name of the containers created |
| resource\_group\_name | The name of the generated resource group |
| sp\_application\_id | The service principal application id |
| sp\_password | The service principal password |
| storage\_account\_location | The location of the generated storage account |
| storage\_account\_name | The name of the generated storage account |
| subscription\_id | Subscription id where the storage account is |
