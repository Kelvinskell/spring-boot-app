variable "env" {
  type = string
}

variable "app" {
  type = string
}

variable "rds_sg" {
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

variable "private_subnet_ids" {
  type = list
}