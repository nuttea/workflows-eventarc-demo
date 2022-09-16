# Create a service account for Workflows
resource "google_service_account" "workflows_service_account" {
  account_id   = var.workflow_sa
  display_name = "Workflows Service Account"
}

resource "google_project_iam_member" "workflows_service_account_roles" {
  project  = var.project_id
  member   = format("serviceAccount:%s", google_service_account.workflows_service_account.email)
  for_each = toset([
    "roles/logging.logWriter",
    "roles/run.invoker",
    "roles/cloudfunctions.invoker",
  ])
  role     = each.key
}

# Define and deploy a workflow
resource "google_workflows_workflow" "workflows_main" {
  name            = var.workflow_name
  region          = var.region
  description     = "${var.workflow_name} in ${var.region}"
  service_account = google_service_account.workflows_service_account.id
  source_contents = file("${path.cwd}/workflows/workflow.yaml")
}