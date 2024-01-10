## Comment out this block and use below for 1password support
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

################

/*
locals {
  op_token = "<one_pass_token>"
  vault_id = "<one_pass_vault>"
}
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
  host = "unix:///var/run/docker.sock"
}
*/
