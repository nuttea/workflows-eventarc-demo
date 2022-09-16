provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  gcf_source_bucket = "${var.project_id}-gcf-source"
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
#resource "google_storage_bucket" "bucket" {
#  name     = local.gcf_source_bucket  # Every bucket name must be globally unique
#  location = "${var.region}"
#  uniform_bucket_level_access = true
#}

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
  gcf_source_bucket = local.gcf_source_bucket
}

module "multiply" {
  source        = "./modules/gcp-functions"
  function_name = "multiply"
  runtime       = "python39"
  region        = var.region
  gcf_source_bucket = local.gcf_source_bucket
}