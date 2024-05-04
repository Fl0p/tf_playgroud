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


variable "yaml_content" {
  type        = string
  description = "Content to be written to the YAML file on the remote host"
  default     = <<EOF
name: Default User
age: 25
email: default@example.com
roles:
  - User
preferences:
  theme: light
  language: en
EOF
}

variable "remote_file_path" {
  type        = string
  description = "Path on the remote host where the YAML file will be created"
  default     = "~/test.yml"  # Optional: provide a default file path
}
