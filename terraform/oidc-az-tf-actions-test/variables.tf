variable "additional_tags" {
  description = "additional tags"
  type        = map(string)
  default = {
    "ttl" = "1h"
  }
}

variable "app_name" {
  description = "app name"
  default     = "thumbelina"
}

variable "azure_region" {
  description = "region"
  default     = "eu-north"
}

variable "dynamic_tags" {
  description = "dynamic stuff to pass from env"
  default     = {}
}
