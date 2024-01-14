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

# Randomizes the container name so multiple workspaces can be run
resource "random_pet" "code_server_name" {
  prefix = "code_server"
  separator = "_"
}

# Randomizes the container port so multiple workspaces can be run
# I'm aware this can potentially generate an in-use port, I'm hoping tf will catch that.
# Otherwise, the docker tf provider does not give me a way to verify in-use ports
resource "random_integer" "code_server_port" {
  min = 8444
  max = 8450
}

# Where the magic happens
resource "docker_container" "codeserver_d_container" {
  image = docker_image.code-server-img.image_id
  name  = random_pet.code_server_name.id
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
    external = random_integer.code_server_port.result
  }
}

# Comment this out if you do not want this password displyed at apply
# NOTE: If left uncommented, password will be stored in plain text in tfstate and hcl.lock
output "code_server_pass" {
  value = nonsensitive(random_password.password.result)
}

# Prints the server URL as output, basically just the random port that changes
output "code_server_url" {
  value = "http://localhost:${random_integer.code_server_port.result}/"
}