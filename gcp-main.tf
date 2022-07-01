# Enable Artifact Registry API
# resource "google_project_service" "artifactregistry" {
#   provider = google-beta
#   service = "artifactregistry.googleapis.com"
#   disable_on_destroy = false
# }

# # Enable Cloud Run API
# resource "google_project_service" "cloudrun" {
#  project = "rds-labdevopscloud"
#  service = "run.googleapis.com"
#  disable_on_destroy = false
# }

# # Enable Cloud Resource Manager API
# resource "google_project_service" "resourcemanager" {
#   project = "rds-labdevopscloud"
#   service  = "cloudresourcemanager.googleapis.com"
#   disable_on_destroy = false
# }

# resource "time_sleep" "wait_30_seconds" {
#   create_duration = "60s"
#   depends_on = [
#     google_project_service.artifactregistry,
#     google_project_service.cloudrun,
#     google_project_service.resourcemanager
#     ]
# }

# Create Artifact Registry Repository for Docker containers
resource "google_artifact_registry_repository" "python-gcp-cloud" {
  provider = google-beta

  location = "us-central1"
  repository_id = "pythongcpcloud"
  description = "Imagens Docker python gco cloud"
  format = "DOCKER"
  # depends_on = [time_sleep.wait_30_seconds]
}

# Deploy image to Cloud Run
resource "google_cloud_run_service" "python-gcp-cloud" {
  name = "python-gcp-cloud"
  location = "us-central1"
  autogenerate_revision_name = true
  metadata {
    annotations = {
      "run.googleapis.com/client-name" = "terraform",
      "autoscaling.knative.dev/minScale" = "0"
      "autoscaling.knative.dev/maxScale" = "1"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/rds-labdevopscloud/pythongcpcloud/python-gcp-cloud"
      }
    }
  }

  depends_on = [google_artifact_registry_repository.python-gcp-cloud]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.python-gcp-cloud.name
  location = google_cloud_run_service.python-gcp-cloud.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "cloud_run_instance_url" {
  value = google_cloud_run_service.python-gcp-cloud.status[0].url
}