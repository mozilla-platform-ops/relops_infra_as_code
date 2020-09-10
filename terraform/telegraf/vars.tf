variable "relay_image" {}
variable "relay_port" {}
variable "webhook_port" {}

variable "relay_count" {}
variable "relay_cpu" {}
variable "relay_memory" {}

variable "workers_image" {}
variable "workers_count" {}
variable "workers_cpu" {}
variable "workers_memory" {}

variable "queue_image" {}
variable "queue_count" {}
variable "queue_cpu" {}
variable "queue_memory" {}

variable "vcs_image" {}
variable "vcs_count" {}
variable "vcs_cpu" {}
variable "vcs_memory" {}

variable "influxdb_url" {
  description = "InfluxDB host url"
  default     = "http://influxdb:8086"
}

variable "influxdb_db" {
  description = "InfluxDB database name"
  default     = "default"
}

variable "influxdb_user" {
  description = "InfluxDB user name"
  default     = "admin"
}

variable "interval" {
  description = "Metric collection default interval"
  default     = "60s"
}

variable "medium_interval" {
  description = "Metric collection medium interval"
  default     = "300s"
}

variable "long_interval" {
  description = "Metric collection long interval"
  default     = "600s"
}
