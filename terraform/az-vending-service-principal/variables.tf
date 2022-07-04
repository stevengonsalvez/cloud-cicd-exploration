# variable "subscription_id" {
#   description = "Required. The subscription ID to use."
# }

variable "owners" {
  description = "Owner of the service principal"
  type        = list(any)
}

variable "app_name" {
  description = "name of the app"
}


variable "subscription_ids" {
  description = "list of subscriptions for access to the service principal"
  type        = list(any)
}


variable "environments" {
  description = "list of environments for federated credentials"
  type        = list(any)
}