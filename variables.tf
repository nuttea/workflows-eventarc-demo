variable "project_id" {
  description = "The project in which the resource belongs."
  type        = string
}

variable "region" {
  description = "The Google Cloud regions for the resources to be created."
  default     = "asia-southeast1"
  type        = string
}

variable "runtime" {
  description = "The runtime of the function."
  default     = "nodejs16"
  type        = string
}

variable "workflow_name" {
  description = "The unique name to identify the function."
  type        = string
}

variable "workflow_sa" {
  description = "The service account for a workflow."
  default     = "workflow-sa"
  type        = string
}