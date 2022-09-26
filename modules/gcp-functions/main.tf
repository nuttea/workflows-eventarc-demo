data "archive_file" "archive" {
  type        = "zip"
  source_dir  = "./${var.function_name}"
  output_path = "${var.function_name}-function-source.zip"
}

resource "google_storage_bucket_object" "object" {
  name   = format("%s.zip#%s", var.function_name, data.archive_file.archive.output_md5)
  bucket = var.gcf_source_bucket
  source = data.archive_file.archive.output_path  # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "function" {
  name = "${var.function_name}"
  location = "${var.region}"
  description = "[Managed by Terraform] ${var.function_name} functions ${data.archive_file.archive.output_md5}"

  build_config {
    runtime = var.runtime
    entry_point = "${var.function_name}"  # Set the entry point 
    source {
      storage_source {
        bucket = var.gcf_source_bucket
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    min_instance_count  = 0
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
    environment_variables = {
        SERVICE_CONFIG_TEST = "config_test"
    }
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    #vpc_connector      = "" # The Serverless VPC Access connector name for Serverless to send Egress traffic to a VPC
    #vpc_connector_egress_settings = "ALL_TRAFFIC"
    all_traffic_on_latest_revision = true
    service_account_email = var.function_service_account_email
  }
}
