provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_pod" "game_server" {
    metadata {
    name = "the-cow-game-server"
    labels = {
      "app" = "cow-game"
    }
  }

  spec {
    container {
      image = "us-west1-docker.pkg.dev/thecowgame/game-images/mmo-server:latest"
      name  = "thecowgameserver"

      port {
        container_port = 6060
      }

      resources{
        limits = {
          cpu = "20m"
          memory = "64Mi"
        }
        requests = {
          cpu = "20m"
          memory = "64Mi"
        }
      }
    }
     image_pull_secrets {
        name = "artifact-registry-secret"
      }
  }
}

resource "kubernetes_service" "headless_service" {
  metadata{
    name = "single-pod-service"
  }
  
  spec {
    type = "NodePort"   # Headless service disables load balancing
    selector = {
      "app" = "cow-game"
    }
    port{
      port = 80
      target_port = 6060
    }
  }
}
resource "kubernetes_ingress_v1" "gke_ingress" {
  metadata {
    name = "playhtecowgame-ingress"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.default.name
      "networking.gke.io/managed-certificates"       = kubernetes_manifest.managed_certificate.manifest["metadata"]["name"]
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = kubernetes_service.headless_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.managed_certificate]
}

# Create the ManagedCertificate Kubernetes resource
resource "kubernetes_manifest" "managed_certificate" {
  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "ManagedCertificate"
    metadata = {
      name      = "playthecowgame-cert"
      namespace = "default"
    }
    spec = {
      domains = [
        "www.playthecowgame.com"
      ]
    }
  }
}
