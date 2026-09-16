variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "app_version" {
  description = "App version from github sha"
  type        = string
  default     = "Dev"
}