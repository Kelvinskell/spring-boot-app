variable "azs" {
  type = list
}

variable "tg_arn" {
  type = string
}

variable "private_subnets" {
  type = list
}

variable "ecs_sg" {
  type = string
}

variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "image_name" {
  type = string
}