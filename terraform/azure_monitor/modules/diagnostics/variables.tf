variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "host_pool_id" {
  type = string
}

variable "retention_days" {
  type    = number
  default = 30
}