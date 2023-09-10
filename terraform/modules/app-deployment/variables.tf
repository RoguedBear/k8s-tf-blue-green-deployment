variable "name" {
  type        = string
  description = "name of the deployment"
}

variable "image" {
  type        = string
  description = "image to use in the container"
}

variable "args" {
  type        = string
  description = "arguments to be passed"
}

variable "port" {
  type        = number
  description = "port of the deployment and service"
}

variable "traffic_weight" {
  type        = number
  description = "ingress-nginx weight distribution"
}

variable "replicas" {
  type        = number
  description = "the number of replicas for this pod"
}
variable "namespace" {
    type = string
    description = "namespace"
    default = "terraform"
}
