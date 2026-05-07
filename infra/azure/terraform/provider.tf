terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.71.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=3.1.0"
    }
  }
  backend "azurerm" {
    use_oidc             = true                                   
    use_azuread_auth     = false                                  
    tenant_id            = "ba0e2544-48a4-4015-8fd2-73da5d682c98" 
    client_id            = "54a08c5e-2ecb-40fb-ae4e-87437cb4a992" 
    storage_account_name = "tfstate458753017"                     
    container_name       = "tfstate"                              
    key                  = "terraform.tfstate"                    
  } 
}

provider "azurerm" {
  resource_provider_registrations = "none" 
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
provider "kubernetes" {
  host                   = local.cluster_address
  client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
}