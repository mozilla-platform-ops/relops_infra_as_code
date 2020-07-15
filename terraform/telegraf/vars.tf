variable "relay_image" {}
variable "relay_port" {}
variable "webhook_port" {}

variable "relay_count" {}
variable "relay_cpu" {}
variable "relay_memory" {}

variable "collection_image" {}
variable "collection_count" {}

variable "collection_cpu" {}
variable "collection_memory" {}

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
