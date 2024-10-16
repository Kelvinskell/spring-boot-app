variable "region" {
  type = string
}

variable "env" {
  type = string
  default = "dev"
}

variable "app" {
  type = string
  default = "spring-boot-app"
}

variable "image_name" {
  type = string
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "sns_email_address" {
  type = string
  description = "The email address to subscribe to SNS Topics"
}