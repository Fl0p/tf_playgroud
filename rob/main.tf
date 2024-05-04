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
