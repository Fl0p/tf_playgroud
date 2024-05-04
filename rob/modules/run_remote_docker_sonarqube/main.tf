terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

#postgres
resource "docker_volume" "postgres" {
  name = "postgres"
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_image" "postgres" {
  name = "postgres:latest"
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "postgres"
  volumes {
    volume_name    = docker_volume.postgres.name
    container_path = "/var/lib/postgresql"
    read_only      = false
  }
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
    read_only      = false
  }
  ports {
    internal = 5432
    external = 5432
  }
  env = [
      "POSTGRES_USER=sonar",
      "POSTGRES_PASSWORD=sonar"
  ]
  restart = "on-failure"
}

resource "docker_volume" "sonarqube_data" {
  name = "${var.remote_username}_sonarqube_data"
}

resource "docker_volume" "sonarqube_logs" {
  name = "${var.remote_username}_sonarqube_logs"
}

resource "docker_volume" "sonarqube_extensions" {
  name = "${var.remote_username}_sonarqube_extensions"
}

resource "docker_image" "sonarqube" {
  name         = "sonarqube:developer"
  keep_locally = true
}

resource "docker_container" "sonarqube" {
  image = docker_image.sonarqube.image_id
  name  = "sonarqube"
  volumes {
    container_path = "/opt/sonarqube/data"
    volume_name    = docker_volume.sonarqube_data.name
  }
  volumes {
    container_path = "/opt/sonarqube/logs"
    volume_name    = docker_volume.sonarqube_logs.name
  }
  volumes {
    container_path = "/opt/sonarqube/extensions"
    volume_name    = docker_volume.sonarqube_extensions.name
  }
  ports {
    internal = 9000
    external = 9000
  }
  env = [
    "SONARQUBE_JDBC_URL=jdbc:postgresql://postgres:5432/sonar",
    "SONARQUBE_JDBC_USERNAME=sonar",
    "SONARQUBE_JDBC_PASSWORD=sonar"
  ]
}

