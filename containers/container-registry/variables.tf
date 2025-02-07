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
  default     = "westus"
}

variable "resource_group_name" {
  type        = string
  default     = "rg"
}

variable "container_registry_name" {
  type        = string
  default     = "registry"
}


variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development",
    "Department" = "IT"
  }
}