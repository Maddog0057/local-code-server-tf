# Create a file called secrets.tf and add the following
/*
locals {
  op_token = "<one_pass_token>"
  vault_id = "<one_pass_vault>"
}
*/
terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 1.3.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.1"
    }
  }
}

provider "onepassword" {
  service_account_token = local.op_token
}

provider "docker" {
  # local docker host
  host = "unix:///var/run/docker.sock"
  # Remote docker host
  #host = "ssh://${data.onepassword_item.remote_docker_creds.username}@${data.onepassword_item.remote_docker_creds.url}"
}

