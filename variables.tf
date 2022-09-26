variable "project_id" {
  description = "The project in which the resource belongs."
  type        = string
}

variable "region" {
  description = "The Google Cloud regions for the resources to be created."
  default     = "asia-southeast1"
  type        = string
}

variable "workflow_group_name" {
  description = "The unique name to identify the group of workflows and functions."
  type        = string
}