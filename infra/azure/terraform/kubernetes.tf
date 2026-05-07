#-- Definición de los namespaces de iDIPyL9K9FXc8ievR5vRmXsgT1

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
