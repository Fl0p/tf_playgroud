resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}

# provider "docker" {
#   host = "tcp://robMini:2376"
# }

# resource "docker_image" "jenkins" {
#   name         = "jenkins/jenkins:lts"
#   keep_locally = false
# }

# resource "docker_container" "jenkins" {
#   image = docker_image.jenkins.latest
#   name  = "jenkins"
#   ports {
#     internal = 8080
#     external = 8080
#   }
# }
