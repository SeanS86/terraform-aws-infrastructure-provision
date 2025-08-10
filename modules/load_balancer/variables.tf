# --- Input Variables ---
variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
}

variable "public_subnet1_id" {
  description = "ID of the first public subnet for the NLB."
  type        = string
}

variable "public_subnet2_id" {
  description = "ID of the second public subnet for the NLB."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the target groups will be created."
  type        = string
}

variable "k8s_node1_id" {
  description = "Instance ID of the first Kubernetes node."
  type        = string
}

variable "k8s_node2_id" {
  description = "Instance ID of the second Kubernetes node."
  type        = string
}

variable "dashboard_node_port" {
  description = "The NodePort assigned to the Kubernetes Dashboard service (kubernetes-dashboard-kong-proxy)."
  type        = number
}