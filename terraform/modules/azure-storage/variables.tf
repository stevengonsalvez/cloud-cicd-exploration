variable "subscription_id" {
  description = "The subscription id to use"
}

variable "resource_group_name" {
  description = "Name of the resource group to create or use"
}

variable "location" {
  description = "Azure region where resources will be created"
}
variable "storage_config" {
  description = "The azure storage configuration"
  type = object({
    storage_type = string
    account_kind = string
    access_tier  = string
  })
}

variable "containers" {
  description = "Name of the containers (1 per environment in a subscription e.g  dev,test,stage in non prod and prod-neu, prod-weu in production)"
  type        = list(string)
}

variable "ip_whitelist" {
  description = "A list of IPs to whitelist"
  type        = list(string)
  default     = []
}

variable "tags" {
  type = map(string)
}