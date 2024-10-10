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