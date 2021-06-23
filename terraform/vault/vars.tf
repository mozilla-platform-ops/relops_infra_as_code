variable "ecs_ami" {
  description = "ECS optimized ami"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
}

variable "docker_version" {
  description = "Version of the terraform docker image"
}
