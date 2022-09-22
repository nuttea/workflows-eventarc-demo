# GCP Cloud Funtion gen2

This module is used to create a Cloud Function with automatic detect code chanage with md5 hash of the code archive file.

## Usage

Example

```terraform
module "randomgen" {
  source        = "./modules/gcp-functions"
  function_name = "randomgen" # Function Name need to match with both "Source Code Folder Name" and "Function Entrypoint"
  runtime       = "nodejs16" # Specify runtime
  region        = var.region
  gcf_source_bucket = google_storage_bucket.bucket.name # GCS Bucket for upload source code archive file to deploy
  function_service_account_email = google_service_account.function_service_account.email # Your Service Account for Function
}
```

## Testing

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | Function Name need to match with both "Source Code Folder Name" and "Function Entrypoint" | `string` | `""` | yes |
| runtime | Cloud Function runtime id. See the current list in [Execution Environment](https://cloud.google.com/functions/docs/concepts/execution-environment)  | `string` | `""` | yes |
| region | The GCP Region to run Cloud Function  | `string` | `asia-southeast1` | no |
| gcf_source_bucket | GCS Bucket for upload source code archive file to deploy  | `string` | `""` | yes |
| function_service_account_email | Service Account for Function  | `string` | `""` | yes |

## Outputs

| Name | Description |
|------|-------------|
| N/A | N/A |