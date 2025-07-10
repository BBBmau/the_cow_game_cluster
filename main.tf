  data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.kubernetes-engine_beta-autopilot-public-cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes-engine_beta-autopilot-public-cluster.ca_certificate)
}

resource "google_compute_network" "cow_cluster" {
  name = "cow-cluster-network"

  auto_create_subnetworks  = false
}

resource "google_compute_subnetwork" "cow_cluster" {
  name = "cow-cluster-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-west1"

  network = google_compute_network.cow_cluster.id

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}


module "kubernetes-engine_beta-autopilot-public-cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-public-cluster"
  version = "37.0.0"
  region = "us-west1"  


  // required inputs
  name = "the-cow-game-cluster"
  project_id = "thecowgame"
  network = google_compute_network.cow_cluster.name
  subnetwork = google_compute_subnetwork.cow_cluster.name
  ip_range_pods = google_compute_subnetwork.cow_cluster.secondary_ip_range.1.range_name
  ip_range_services = google_compute_subnetwork.cow_cluster.secondary_ip_range.0.range_name
  network_tags = ["game-server"]
}
