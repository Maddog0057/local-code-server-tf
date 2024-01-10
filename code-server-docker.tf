# Pulls https://docs.linuxserver.io/images/docker-code-server/
# And stores in Docker's internal image repository
resource "docker_image" "code-server-img" {
  name = "lscr.io/linuxserver/code-server:latest"
}

# Pulls config script into terraform
data "local_file" "config_script" {
  filename = "./code-server-setup.sh"
}

# Generates a random 32 character password to be used for sudo auth
# This password will be displayed as an output value
# NOTE: password will not change unless terraform destroy is run!
resource "random_password" "password" {
  length           = 32
  special          = true
}

resource "docker_container" "codeserver_d_container" {
  image = docker_image.code-server-img.image_id
  name  = "codeserver-docker-local"
  entrypoint = [
    "/bin/bash",
    "-c",
    "${data.local_file.config_script.content}"
  ]
  env = [
    "SUDO_PASSWORD=${random_password.password.result}",
    "PGID=1000",
    "PUID=1000",
    "TZ=America/New_York"
  ]
  mounts {
    target = "/config"
    type   = "volume"
  }
  ports {
    internal = 8443
    external = 8443
  }
}

# Comment this out if you do not want this password displyed at apply
# NOTE: If left uncommented, password will be stored in plain text in tfstate and hcl.lock
output "random_pass" {
  value = nonsensitive(random_password.password.result)
}

# Uncomment for 1Password Support
/*
resource "onepassword_item" "cs_sudo_login" {
  vault    = local.vault_id
  title    = "Local Code Server Sudo"
  category = "login"
  username = "root"
  password_recipe {
    length  = 32
    symbols = true
  }
}
*/

## Replace the container's ENV with the following
/*
env = [
    "SUDO_PASSWORD=${onepassword_item.cs_sudo_login.password}",
    "PGID=1000",
    "PUID=1000",
    "TZ=America/New_York"
  ]
*/