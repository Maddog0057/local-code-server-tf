# Create a file called secrets.tf and add the following
/*
locals {
  op_token = "<one_pass_token>"
  vault_id = "<one_pass_vault>"
  gl_token = "<gitlab 1p id>"
  gl_user = "<gitlab user>"
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
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = ">= 16.8.1"
    }
  }
}

data onepassword_item "gitlab_creds" {
  vault = local.vault_id
  uuid = local.gl_token
}

provider "gitlab" {
  token = data.onepassword_item.gitlab_creds.password
}

provider "onepassword" {
  service_account_token = local.op_token
}

/*
data onepassword_item "remote_docker_creds" {
  vault = local.vault_id
  uuid = local.op_ssh_id
}
*/

provider "docker" {
  # local docker host
  host = "unix:///var/run/docker.sock"
  # Remote docker host
  #host = "ssh://${data.onepassword_item.remote_docker_creds.username}@${data.onepassword_item.remote_docker_creds.url}"
}

