# Create Artifact Registry Repository for Docker containers
resource "google_artifact_registry_repository" "python-gcp-cloud" {
  provider = google-beta

  location = "us-central1"
  repository_id = "pythongcpcloud"
  description = "Imagens Docker python gco cloud"
  format = "DOCKER"
}

# Enable Cloud Run API
resource "google_project_service" "run" {
  provider = google-beta
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Deploy image to Cloud Run
resource "google_cloud_run_service" "python-gcp-cloud" {
  name     = "python-gcp-cloud"
  location = "us-central"

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
}

# Create a policy that allows all users to invoke the API
data "google_iam_policy" "noauth" {
  provider = google-beta
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Apply the no-authentication policy to our Cloud Run Service.
resource "google_cloud_run_service_iam_policy" "noauth" {
  provider = google-beta
  location    = "us-central"
  project     = "rds-labdevopscloud"
  service     = google_cloud_run_service.python-gcp-cloud.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

output "cloud_run_instance_url" {
  value = google_cloud_run_service.python-gcp-cloud.status.0.url
}