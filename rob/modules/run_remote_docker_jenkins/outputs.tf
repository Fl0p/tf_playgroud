output "jenkins_admin_password" {
  value       = data.local_file.jenkins_admin_password.content
  description = "Jenkins initial Administrator password"
}

