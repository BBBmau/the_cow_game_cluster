provider "kubernetes" {
  host                   = "https://${module.kubernetes-engine_beta-autopilot-public-cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes-engine_beta-autopilot-public-cluster.ca_certificate)
}