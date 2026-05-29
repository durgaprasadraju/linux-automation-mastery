variable "region" {
  default = "us-east-1"
}

variable "app_secret" {
  type      = string
  sensitive = true
}