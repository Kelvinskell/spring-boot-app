variable "env" {
  type = string
}

variable "app" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "region" {
  type = string
}

variable "single_notification" {
  description = "Set to true to notify only once, false to notify multiple times"
  type        = bool
  default     = true  # Change to false if you want multiple notifications by default
}

variable "sns_email_address" {
  type = string
  description = "The email address to subscribe to SNS Topics"
}