variable "env" {
  type = string
}

variable "public_subnets" {
  type = list(any)
}

variable "alb_sg" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app" {
  type = string
}