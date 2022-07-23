variable "ssm_name" {
  type = string
}

variable "domains" {
  type = list(string)
}

variable "organization" {
  type        = string
  description = "Name for cert issuing org"
}
