resource "kubernetes_namespace" "homelab_ns" {
  metadata {
    annotations = {
      name = var.base.name
    }

    labels = {
      tier = "base"
    }

    name = var.base.name
  }

  provider = k8s
}
