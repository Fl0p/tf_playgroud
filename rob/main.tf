terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.23.0"
    }
  }
}

resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}

provider "docker" {
  # host = "unix:///var/run/docker.sock"
  # host = "tcp://robMini:2376"
  host = "ssh://rob@robMini:22"
  ssh_opts = [
    # "-o", "StrictHostKeyChecking=no",
    # "-o", "UserKnownHostsFile=/dev/null",
  ]
}

resource "docker_volume" "shared_volume1" {
  name = "shared_volume1"
}

resource "docker_image" "jenkins" {
  name         = "jenkins/jenkins:lts"
  keep_locally = true
}

resource "docker_container" "jenkins" {
  image = docker_image.jenkins.image_id
  name  = "jenkins"
  volumes {
    container_path = "/var/jenkins_home"
    host_path = "/Users/rob/jenkins_home"
  }
  ports {
    internal = 8080
    external = 8080
  }
}
