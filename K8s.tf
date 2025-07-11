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
        container_port = 8080
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
      target_port = 8080
    }
  }
}