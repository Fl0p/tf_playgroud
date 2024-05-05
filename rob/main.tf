terraform {
  backend "s3" {
    endpoint                    = "fra1.digitaloceanspaces.com"
    bucket                      = "robtfstate"
    key                         = "rob/terraform.tfstate"
    region                      = "eu-central-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  # backend "local" {
  #   path = ".tfstate/terraform.tfstate"
  # }
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

provider "docker" {
  host     = "ssh://${var.runner_user}@${var.runner_ip}:${var.runner_port}"
  ssh_opts = []
}

module "create_yaml_file" {
  source           = "./modules/create_remote_yaml"
  remote_host_ip   = var.runner_ip
  remote_host_port = var.runner_port
  remote_username  = var.runner_user
  remote_file_path = "~/ngrok.yml"
  # Override only what's necessary, if anything
}

output "create_yaml_file_output" {
  value = "YAML file created successfully at ${module.create_yaml_file.remote_file_path}"
}


module "run_remote_docker_jenkins" {
  source = "./modules/run_remote_docker_jenkins"
  providers = {
    docker = docker
  }
  remote_host_ip   = var.runner_ip
  remote_host_port = var.runner_port
  remote_username  = var.runner_user
}

output "jenkins_admin_password" {
  value = module.run_remote_docker_jenkins.jenkins_admin_password
}


module "run_remote_docker_sonarqube" {
  source           = "./modules/run_remote_docker_sonarqube"
  remote_host_ip   = var.runner_ip
  remote_host_port = var.runner_port
  remote_username  = var.runner_user
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
