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
  default = "westus"
}

variable "resource_group_name" {
  type    = string
  default = "rg"
}


variable "asp_name" {
  type    = string
  default = "linux-asp"
}

variable "app_name" {
  type    = string
  default = "app"
}


variable "app_environment_name" {
  type    = string
  default = "app-env"
}

variable "asp_os" {
  type    = string
  default = "Linux"
}

variable "asp_sku" {
  type    = string
  default = "P0v3"
}

variable "vnet_name" {
  type    = string
  default = "vnet"
}

variable "default_subnet_name" {
  type    = string
  default = "default"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development",
    "Department"  = "IT"
  }
}
