resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }
      spec {
        container {
          name  = var.name
          image = var.image
          args  = [var.args]
          resources {
            limits = {
              memory = "50M"
              cpu    = "50m"
            }
          }
          port {
            container_port = var.port
          }
        }
      }
    }
  }
}
