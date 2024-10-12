variable "vpc_id" {
  type = string
}

variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "lambda_eni_policy" {
  description = "The eni policy attached to the lambda role"
}