variable "region" {
  description = "The Google Cloud regions for the resources to be created."
  default     = "asia-southeast1"
  type        = string
}

variable "workflow_name" {
  description = "The unique name to identify the workflow."
  type        = string
}