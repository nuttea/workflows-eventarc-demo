provider "google" {
  project = var.project_id
  region  = var.region
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 13.0"

  project_id = var.project_id

  activate_apis = [
    "iam.googleapis.com", 
    "cloudresourcemanager.googleapis.com",
    "eventarc.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "storage.googleapis.com",
    "containerregistry.googleapis.com",
    "artifactregistry.googleapis.com",
    "workflows.googleapis.com"
  ]

  disable_dependent_services = false
  disable_services_on_destroy = false
}

# Pre-requiste to have a GCS Bucket name with format "<project-id>-gcf-source"
resource "google_storage_bucket" "bucket" {
  name     = "${var.project_id}-${var.workflow_name}-gcf-source"  # Every bucket name must be globally unique
  location = "${var.region}"
  uniform_bucket_level_access = true
}

# Service Account for Functions
resource "google_service_account" "function_service_account" {
  account_id = "${var.workflow_name}-function-sa"
  display_name = "Service Account for Cloud Function in ${var.workflow_name} workflow"
}

resource "google_project_iam_member" "gke1_service_account_roles" {
  project  = "${var.project_id}"
  member   = format("serviceAccount:%s", google_service_account.function_service_account.email)
  for_each = toset([
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/cloudfunctions.invoker",
    "roles/run.invoker"
  ])
  role     = each.key
}


# Workflows and Functions modules
module "main-workflow" {
  source        = "./modules/gcp-workflows-trigger-gcs"
  workflow_name = var.workflow_name
  project_id    = var.project_id
}

module "randomgen" {
  source        = "./modules/gcp-functions"
  function_name = "randomgen"
  runtime       = "nodejs16"
  region        = var.region
  gcf_source_bucket = google_storage_bucket.bucket.name
  function_service_account_email = google_service_account.function_service_account.email
}

module "multiply" {
  source        = "./modules/gcp-functions"
  function_name = "multiply"
  runtime       = "python39"
  region        = var.region
  gcf_source_bucket = google_storage_bucket.bucket.name
  function_service_account_email = google_service_account.function_service_account.email
}

module "floor" {
  source        = "./modules/gcp-functions"
  function_name = "floor"
  runtime       = "python39"
  region        = var.region
  gcf_source_bucket = google_storage_bucket.bucket.name
  function_service_account_email = google_service_account.function_service_account.email
}