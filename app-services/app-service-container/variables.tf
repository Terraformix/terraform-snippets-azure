variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type    = string
  default = "rg"
}

variable "app_service_plan_name" {
  type    = string
  default = "linux-asp"
}


variable "app_service_plan_sku" {
  type    = string
  default = "P0v3"
}

variable "app_service_name" {
  type    = string
  default = "app"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development"
    "Department"  = "IT"
  }
}
