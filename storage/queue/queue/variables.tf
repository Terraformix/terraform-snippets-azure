variable "subscription_id" {
  type        = string
}

variable "client_id" {
  type        = string
}

variable "client_secret" {
  type        = string
}

variable "tenant_id" {
  type        = string
}

variable "location" {
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  type    = string
  default = "rg"
}

variable "storage_account_name" {
  type        = string
  default     = "storage"
}

variable "common_tags" {
  description = "Common tags to be applied across multiple resources"
  type = map(string)
  default = {
    "Environment" = "Development",
    "Department" = "IT"
  }
}
