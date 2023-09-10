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
          args = [
            for match in regexall("(-[A-Za-z_]+=(?:\\\".+\\\"|[^ ]+))", var.args) :
            match[0]
          ]
          # Yes. This is a hardcoded regex specifically to extract listen and text
          # together   
          # https://regex101.com/r/pOqCN1/2

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

resource "kubernetes_service" "service" {
  metadata {
    name      = format("%s-svc", var.name)
    namespace = var.namespace
  }
  spec {
    selector = {
      app = var.name
    }
    port {
      port        = var.port
      target_port = var.port
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name      = format("%s-ingress", var.name)
    namespace = var.namespace
    labels = {
      name = format("%s-ingress", var.name)
    }
    annotations = {
      "nginx.ingress.kubernetes.io/canary"        = "true"
      "nginx.ingress.kubernetes.io/canary-weight" = format("%d", var.traffic_weight)
    }
  }
  spec {
    rule {
      http {
        path {
          backend {
            service_name = kubernetes_service.service.metadata.0.name
            service_port = var.port
          }
        }
      }
    }
  }
}
