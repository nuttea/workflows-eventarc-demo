locals {
  project           = "nuttee-lab-02"
  region            = "asia-southeast1"
  function_name     = "randomgen"
}

provider "google" {
  project = "${local.project}"
  region  = "${local.region}"
}

provider "archive" {
}

resource "google_storage_bucket" "bucket" {
  name     = "${local.project}-gcf-source"  # Every bucket name must be globally unique
  location = "${local.region}"
  uniform_bucket_level_access = true
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = "./${local.function_name}"
  output_path = "${local.function_name}-function-source.zip"
}

resource "google_storage_bucket_object" "object" {
#  name   = "${local.function_name}-function-source.zip" # 
  name   = format("%s-%s.zip", local.function_name, data.archive_file.archive.output_md5)
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.archive.output_path  # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "function" {
  name = "${local.function_name}"
  location = "${local.region}"
  description = "[Managed by Terraform] ${local.function_name} functions ${data.archive_file.archive.output_md5}"

  build_config {
    runtime = "nodejs16"
    entry_point = "${local.function_name}"  # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket_object.object.bucket
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
  }
}
