variable "vpc_id" {
  type = string
}

variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "lambda_iam_role" {
  description = "The role attached to the lambda resource"
}