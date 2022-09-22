variable "region" {
  description = "The Google Cloud regions for the resources to be created."
  default     = "asia-southeast1"
  type        = string
}

variable "function_name" {
  description = "The unique name to identify the function."
  type        = string
}

variable "runtime" {
  description = "The runtime of the function."
  type        = string
}

variable "gcf_source_bucket" {
  description = "The GCS Bucket for Cloud Functions source archive upload."
  type        = string
}

variable "function_service_account_email" {
  description = "The Cloud Function Service Account Email"
  type        = string
}