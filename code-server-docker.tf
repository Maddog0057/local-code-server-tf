# Pulls https://docs.linuxserver.io/images/docker-code-server/
# And stores in Docker's internal image repository
resource "docker_image" "code-server-img" {
  name = "lscr.io/linuxserver/code-server:latest"
}

# Pulls config script into terraform
data "local_file" "config_script" {
  filename = "./code-server-setup.sh"
}

resource "random_pet" "code_server_name" {
  separator = "_"
}

resource "random_integer" "code_server_port" {
  min = 8444
  max = 8450
}

resource "tls_private_key" "cs_ed25519" {
  algorithm = "ED25519"
}

resource "onepassword_item" "cs_sudo_login" {
  vault    = local.vault_id
  title    = "Code Server ${random_pet.code_server_name.id} Sudo"
  url      = "http://localhost:${random_integer.code_server_port.result}/"
  category = "login"
  username = "root"
  password_recipe {
    length  = 32
    symbols = true
  }
  section {
    label = "cs_pk"
    field {
      label = "pubKey"
      type  = "STRING"
      value = tls_private_key.cs_ed25519.public_key_openssh
    }
    field {
      label = "pubKey-sha256"
      type  = "STRING"
      value = tls_private_key.cs_ed25519.public_key_fingerprint_sha256
    }
  }
}

resource "docker_container" "codeserver_container" {
  image = docker_image.code-server-img.image_id
  name  = "Code_Server_${random_pet.code_server_name.id}"
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
  upload {
    file    = "/config/.ssh/id_ed25519.pub"
    content = sensitive(tls_private_key.cs_ed25519.public_key_openssh)
  }
  upload {
    file    = "/config/.ssh/id_ed25519.sha256"
    content = sensitive(tls_private_key.cs_ed25519.public_key_fingerprint_sha256)
  }
  ports {
    ip = "127.0.0.1"
    internal = 8443
    external = random_integer.code_server_port.result
  }
}

output "code_server_name" {
  value = random_pet.code_server_name.id
}

output "code_server_url" {
  value = "http://localhost:${random_integer.code_server_port.result}/"
}
