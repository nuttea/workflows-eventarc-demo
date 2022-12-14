data "google_project" "project" {
}

# Create a service account for Workflows
resource "google_service_account" "workflows_service_account" {
  account_id   = "${var.workflow_name}-workflow-sa"
  display_name = "Workflows Service Account for ${var.workflow_name} workflow"
}

resource "google_project_iam_member" "workflows_service_account_roles" {
  project  = data.google_project.project.id
  member   = format("serviceAccount:%s", google_service_account.workflows_service_account.email)
  for_each = toset([
    "roles/logging.logWriter",
    "roles/run.invoker",
    "roles/cloudfunctions.invoker",
    "roles/secretmanager.secretAccessor"
  ])
  role     = each.key
}

# Define and deploy a workflow
resource "google_workflows_workflow" "workflows_main" {
  name            = var.workflow_name
  region          = var.region
  description     = "${var.workflow_name} in ${var.region}"
  service_account = google_service_account.workflows_service_account.id
  source_contents = file("${path.cwd}/${var.workflow_name}/workflow.yaml")
}