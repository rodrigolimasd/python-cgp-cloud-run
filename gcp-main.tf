resource "google_app_engine_application" "app" {
  project     = "rds-labdevopscloud"
  location_id = "us-central"
}

resource "google_artifact_registry_repository" "python-gcp-cloud" {
  provider = google-beta

  location = "us-central1"
  repository_id = "pythongcpcloud"
  description = "Imagens Docker python gco cloud"
  format = "DOCKER"
}