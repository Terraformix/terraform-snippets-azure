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

variable "container_environment_name" {
  type        = string
  default     = "environment"
}

variable "container_app_name" {
  type        = string
  default     = "app"
}


variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development",
    "Department" = "IT"
  }
}