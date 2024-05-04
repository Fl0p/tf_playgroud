terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
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
    host_path = var.remote_jenkins_home
  }
  ports {
    internal = 8080
    external = 8080
  }
}

resource "null_resource" "read_jenkins_password" {
  depends_on = [docker_container.jenkins]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo ${docker_container.jenkins.name}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.remote_username
      host        = var.remote_host_ip
      port        = var.remote_host_port
    }

    inline = [
      "docker exec ${docker_container.jenkins.name} cat /var/jenkins_home/secrets/initialAdminPassword > /tmp/jenkins_admin_password"
    ]

  }

  provisioner "local-exec" {
    command = "scp -P ${var.remote_host_port} ${var.remote_username}@${var.remote_host_ip}:/tmp/jenkins_admin_password /tmp/jenkins_admin_password"
  }

}

data "local_file" "jenkins_admin_password" {
  filename = "/tmp/jenkins_admin_password"
  depends_on = [null_resource.read_jenkins_password]
}
