terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    ngrok = {
      source  = "ngrok/ngrok"
      version = "~> 0.3.0"
    }
  }
}


module "create_yaml_file" {
  source = "./modules/create_remote_yaml"
  remote_host_ip = var.runner_ip
  remote_host_port = var.runner_port
  remote_username = var.runner_user
  remote_file_path = "~/test_2.yml"
  # Override only what's necessary, if anything
}

output "confirmation" {
  value = "YAML file created successfully at ${module.create_yaml_file.remote_file_path}"
}


resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}


# Configure the ngrok provider
provider "ngrok" {
  api_key = var.ngrok_api_key
}

# resource "ngrok_reserved_domain" "example" {
#   name = "myapp.exampledomain.com"
#   region = "eu"
# }

provider "docker" {
  host = "ssh://${var.runner_user}@${var.runner_ip}:${var.runner_port}"
  ssh_opts = [
    # "-o", "StrictHostKeyChecking=no",
    # "-o", "UserKnownHostsFile=/dev/null",
  ]
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
      user        = var.runner_user
      host        = var.runner_ip
      port        = var.runner_port
    }

    inline = [
      "docker exec ${docker_container.jenkins.name} cat /var/jenkins_home/secrets/initialAdminPassword > /tmp/jenkins_admin_password"
    ]

  }

  provisioner "local-exec" {
    command = "scp -P ${var.runner_port} ${var.runner_user}@${var.runner_ip}:/tmp/jenkins_admin_password /tmp/jenkins_admin_password"
  }

}

data "local_file" "jenkins_admin_password" {
  filename = "/tmp/jenkins_admin_password"
  depends_on = [null_resource.read_jenkins_password]
}
