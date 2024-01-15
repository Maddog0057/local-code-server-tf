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
    routeros = {
      source = "terraform-routeros/routeros"
      version = ">= 1.31.0"
    }
    wireguard = {
      source = "OJFord/wireguard"
      version = ">= 0.2.2"
    }
  }
}

provider "onepassword" {
  service_account_token = local.op_token
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "onepassword_item" "ros_api_creds" {
  vault = local.vault_id
  uuid = local.ros_op_id
}

data "onepassword_item" "ros_ca_cert" {
  vault = local.vault_id
  uuid = local.ros_ca_cert
}

provider "routeros" {
  hosturl        = data.onepassword_item.ros_api_creds.url
  username       = data.onepassword_item.ros_api_creds.username
  password       = data.onepassword_item.ros_api_creds.password
  ca_certificate = data.onepassword_item.ros_ca_cert.content
  insecure       = true
}