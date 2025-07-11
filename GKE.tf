// used within the k8s provider block
data "google_client_config" "default" {}

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

resource "google_container_cluster" "primary" {
  name     = "the-cow-game-cluster"
  location = "us-west1"

lifecycle {

   prevent_destroy = true

 }
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "cow-node-pool"
  location   = "us-west1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = "cluster-manager@thecowgame.iam.gserviceaccount.com"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
