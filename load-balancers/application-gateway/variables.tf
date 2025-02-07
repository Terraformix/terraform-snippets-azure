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

variable "vmss_username" {
  type    = string
  default = "localadmin"
}

variable "vmss_password" {
  type      = string
  sensitive = true
  default   = "p@ssw0rd12345"
}

variable "vmss_weather_name" {
  type    = string
  default = "weather"
}

variable "vmss_news_name" {
  type    = string
  default = "news"
}

variable "appgw_name" {
  type    = string
  default = "appgw"
}

variable "appgw_sku" {
  type    = string
  default = "Standard_v2"
}

variable "common_tags" {
  description = "Common tags to be applied across multiple resources"
  type        = map(string)
  default = {
    "Environment" = "Development",
    "Department"  = "IT"
  }
}
