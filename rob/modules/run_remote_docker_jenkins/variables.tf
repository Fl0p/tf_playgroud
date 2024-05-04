variable "remote_host_ip" {
  type        = string
  description = "IP address of the remote host"
  default     = "192.168.1.100"  # Example default IP, change as necessary
}

variable "remote_host_port" {
  type        = string
  description = "Port of the remote host"
  default     = "22"  # Example default Port, change as necessary
}

variable "remote_username" {
  type        = string
  description = "Username for SSH access to the remote host"
  default     = "admin"  # Optional: provide a default username if common
}

variable "remote_jenkins_home" {
  type        = string
  description = "jenkins working directory on the remote host"
  default     = "~/jenkins_home" #Optional: provide a default jenkins home if common
}
