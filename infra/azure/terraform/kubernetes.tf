#-- Definición de los namespaces de Kubernetes

resource "kubernetes_namespace_v1" "autokratech" {
  metadata {
    annotations = {
      name = "autokratech"
    }
    labels = {
      project = "autokratech"
    }
    name = "autokratech"
  }
}
