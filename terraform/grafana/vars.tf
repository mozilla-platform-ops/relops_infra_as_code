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

variable "db_username" {
  description = "Database username"
}
