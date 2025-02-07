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


variable "sqlserver_username" {
  type    = string
  default = "localadmin"
}

variable "sqlserver_password" {
  type    = string
  default = "p@ssw0rd12345"
}

variable "sqlserver_name" {
  type    = string
  default = "sqlserver"
}


variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development",
    "Department"  = "IT"
  }
}