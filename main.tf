  data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.kubernetes-engine_example_simple_autopilot_public.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes-engine_example_simple_autopilot_public.ca_certificate)
}

module "kubernetes-engine_example_simple_autopilot_public" {
  source  = "terraform-google-modules/kubernetes-engine/google//examples/simple_autopilot_public"
  version = "37.0.0"
  project_id = var.project_id
  region = var.region
}
