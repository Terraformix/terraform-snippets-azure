locals {
  private_endpoint_name = lower("pe-${var.resource_name}-${var.subresource_name}")
}