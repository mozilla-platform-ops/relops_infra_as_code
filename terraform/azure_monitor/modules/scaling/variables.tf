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

variable "time_zone" {
  type    = string
  default = "Pacific Standard Time"
}

variable "ramp_up_start" {
  type    = string
  default = "08:00"
}

variable "peak_start" {
  type    = string
  default = "09:00"
}

variable "ramp_down_start" {
  type    = string
  default = "17:00"
}

variable "off_peak_start" {
  type    = string
  default = "18:00"
}
