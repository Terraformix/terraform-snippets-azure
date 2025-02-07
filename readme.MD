# Azure Infrastructure Terraform Snippets

A comprehensive collection of Terraform code snippets for deploying various Azure infrastructure resources. This repository provides reusable Infrastructure as Code (IaC) templates for common Azure services and scenarios.

## 🎯 Overview

This repository contains Terraform configurations for deploying and managing Azure resources. Each snippet is organized by service category and includes necessary configurations for common deployment scenarios.

## 📂 Repository Structure


### ⚖️ Load Balancers

- **Application Gateway**
  - Deploy Application gateway with multiple Virtual Machine Scale sets as Backend pools
  - Deploy Nginx application on each instance
  - Configure Path-based URL routing to route traffic at Layer 7 to specific backend pools

- **Load Balancer**
  - Deploy Load Balancer with multiple Virtual Machine Scale sets as Backend pools
  - Deploy Nginx application on each instance
  - Configure Port-based routing to route traffic at Layer 4 to specific backend pools
  - Configure inbound NAT rules for troubleshooting direct SSH access to backend pool instances

### 🏗️ Kubernetes

- **AKS Clusters**
  - Deploy Kubernetes cluster with multiple node pools (default and custom pool)

### 🖥️ Virtual Machines

- **Availability Sets**
  - Deploy Virtual machine Availability Set with Update and Fault domains for data center level redundancy

- **Scale Sets**
  - Deploy Virtual machine Scale Sets with multiple instances

- **Virtual Machine**
  - Deploy simple Virtual Machine

- **Private DNS Zones**
  - Deploy multiple Virtual Machines with internal name resolution using a Private DNS Zone

- **Storage Account Integration**
  - Deploy Virtual Machine accessing a Storage account via a dedicated private IP within the Virtual Network for secure, private connectivity.
  - Deploy Virtual Machine accessing a Storage account securely over the Azure backbone, using the service’s public IP, restricted to a specific VNet subnet.


### 🌐 App Services

- **App Service (Code)**
  - Deploy App Service using source code

- **App Service (Containers)**
  - Deploy App Service using a Container image

- **App Service with Autoscale**
  - Depploy App Service with automatic scaling based on metrics

- **Deployment Slots**
  - Deploy App Service with Deployment slots for configuring multiple environments

- **App Service Environments**
  - Deploy App Service into its own dedicated Virtual Network as part of a single-tenant platform

- **VNet Integration**
  - Deploy App Service to allow Outbound traffic from the App Service to resources inside a Virtual network


### 🐳 Containers

- **Container Apps**
  - Deploy Container App with a single revision and enabled Ingress traffic to allow HTTP traffic

- **Container Instances**
  - Deploy Container Instance with a simple container and allow HTTP traffic

- **Container Registry**
  - Deploy Container Registry to store Container images


### 🛜 Networking

- **Bastion Host**  
  - Deploy Bastion Host to allow secure RDP and SSH access to Virtual Machines in a Virtual network
  - Deploy Virtual Machine with no public IP exposure to test Bastion connectivity via the Azure Portal

- **VNet Peering**
  - Deploy Virtual networks and configure Peering between them allowing for communication across Virtual networks


### 🔒Security

- **Key Vault (RBAC)**
  - Deploy Key Vault with the recommended RBAC model
  - Assign RBAC role to Service Principal to allow Administrative tasks

- **Key Vault (Access Policies)**
  - Deploy Key Vault with Access Policies (Not recommended)
  - Assign Access Policy to Service Principal to allow Administrative tasks


### 💾 Databases and Storage

- **Blob Storage**
  - Deploy Storage Account and a Container with a Blob
  - Deploy Storage Account and a Container with Lifecycle management rules to automatically tier blobs based on name prefix to more cost effective options

- **File Storage**
  - Deploy Storage Account and a File share

- **Queue Storage**
  - Deploy Storage Account and a Queue

- **Table Storage**
  - Deploy Storage Account and a Table

- **SQL Server DB**
  - Deploy managed SQL database with firewall rules


## 🚀 Getting Started

1. Clone this repository
```bash
git clone https://github.com/Terraformix/terraform-snippets.git
cd terraform-snippets
```

2. Install [Terraform](https://www.terraform.io/downloads.html)

3. Authenticate with Azure and set your subscription:
```bash
az login
az account set --subscription="SUBSCRIPTION_ID"
```

4. Create a Service Principal for Terraform
```bash
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes "subscriptions/SUBSCRIPTION_ID"
```

5. Store the values of the Service principal in a .tfvars file (Include this file in your .gitignore)
```bash
client_id       = "xxx"
tenant_id       = "xxx"
subscription_id = "xxx"
client_secret   = "xxx"
```

6. Navigate to desired resource directory

7. Initialize Terraform:
```bash
terraform init
```

8. Review and modify variables in `terraform.tfvars`

9. Deploy infrastructure:
```bash
terraform plan
terraform apply
```

## 📋 Prerequisites

- Azure Subscription
- Azure CLI
- Terraform >=1.8.0
- Service Principal with required permissions
