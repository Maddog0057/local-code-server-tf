# Pulls https://docs.linuxserver.io/images/docker-code-server/
# And stores in Docker's internal image repository
resource "docker_image" "code-server-img" {
  name = "lscr.io/linuxserver/code-server:latest"
}

# Pulls config script into terraform
data "local_file" "config_script" {
  filename = "./code-server-setup.sh"
}

resource "docker_container" "codeserver_d_container" {
  image = docker_image.code-server-img.image_id
  name  = random_pet.code_server_name.keepers.container_name
  entrypoint = [
    "/bin/bash",
    "-c",
    "${data.local_file.config_script.content}"
  ]
  env = [
    "SUDO_PASSWORD=${onepassword_item.cs_sudo_login.password}",
    "PGID=1000",
    "PUID=1000",
    "TZ=America/New_York"
  ]
  mounts {
    target = "/config"
    type   = "volume"
  }
  ports {
    internal = random_integer.code_server_port
    external = random_integer.code_server_port
  }
}

resource "onepassword_item" "cs_sudo_login" {
  vault    = local.vault_id
  title    = "${docker_container.name} Sudo"
  category = "login"
  username = "root"
  password_recipe {
    length  = 32
    symbols = true
  }
}

resource "random_pet" "code_server_name" {
  keepers = {
    container_name = docker_container.name
  }
  prefix = "code_server_"
  separator = "_"
}

resource "random_integer" "code_server_port" {
  min = 8444
  max = 8450
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    listener_val = random_pet.code_server_name
  }
}