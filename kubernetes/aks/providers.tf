terraform {
  required_version = ">=1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.this.kube_config.0.host
  username               = data.azurerm_kubernetes_cluster.this.kube_config.0.username
  password               = data.azurerm_kubernetes_cluster.this.kube_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)

  // When attempting to destroy the cluster, uncomment so that we reference the config file pointing to the cluster which contains the all necessary configuration details for accessing AKS cluster
  // Otherwise it will attempt to connect to localhost by default since the data sources will be empty
  // config_path            = "~/.kube/config"
}