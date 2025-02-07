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

variable "resource_group_name" {
  type    = string
  default = "rg"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "vm_name" {
  type    = string
  default = "vm"
}

variable "vm_username" {
  type    = string
  default = "localadmin"
}

variable "vm_password" {
  type      = string
  sensitive = true
  default   = "p@ssw0rd12345" # Consider using `sensitive = true` for security
}

variable "vm_sku" {
  type    = string
  default = "Standard_DS1_v2"
}


variable "storage_account_name" {
  type    = string
  default = "storageacc"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Environment" = "Development"
    "Department"  = "IT"
  }
}
