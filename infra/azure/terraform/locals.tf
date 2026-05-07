locals {
  docker_repository    = azurerm_container_registry.default.login_server
  cluster_address      = azurerm_kubernetes_cluster.default.kube_config[0].host
  kubernetes_namespace = kubernetes_namespace_v1.autokratech.metadata[0].name
}