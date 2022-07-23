variable "name" {
  type = string
}

variable "remotestate_role" {
  type        = string
  description = "IAM role ARN fopr accessing terraform backend"
}