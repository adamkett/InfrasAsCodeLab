#######################################################################
# terraform server config
#
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

#######################################################################
# mycroft
# - Docker via SSH 
#
provider "docker" {
  host     = "ssh://adam@mycroft:22"
  alias    = "docker-lab-mycroft"
}

resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}

resource "docker_container" "dlm-nginx1" {
  name = "dlm-nginx1"
  provider = docker.docker-lab-mycroft
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 8001
  }
}

resource "docker_container" "dlm-nginx2" {
  name = "dlm-nginx2"
  provider = docker.docker-lab-mycroft
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 8002
  }
}
