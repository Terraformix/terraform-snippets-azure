variable "location" {
  type        = string
}

variable "private_connection_resource_id" {
  type        = string
}

variable "resource_group_name" {
  default     = "rg"
  type        = string
}

variable "resource_name" {
  type        = string
}

variable "subresource_name" {
  type        = string
}

variable "subnet_id" {
  type        = string
}

variable "private_service_connection_name" {
  type        = string
}

variable "private_dns_zone_group_name" {
  type        = string
}

variable "private_dns_zone_ids" {
  type        = list(string)
}


variable "common_tags" {
  type        = map(string)
  default = {
    "Environment" = "Development",
    "Department"  = "IT"
  }
}
