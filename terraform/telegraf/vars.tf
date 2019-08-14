variable "app_count" {
  description = "Number of application instances"
}

variable "app_image" {
  description = "Docker Hub slug"
}

variable "fargate_cpu" {
  description = "Maximum number of instances in the cluster"
}

variable "fargate_memory" {
  description = "Minimum number of instances in the cluster"
}

variable "app_port" {
  description = "Port number of application"
}

variable "webhook_port" {
  description = "Port number of application webhook handler"
}

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
