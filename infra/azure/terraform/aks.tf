#-- Definición clúster de Kubernetes 

resource "azurerm_kubernetes_cluster" "default" {
  name                = "autokratech-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "autokratech"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v3"
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.default.kube_config[0].client_certificate
  sensitive = true
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw

  sensitive = true
}
