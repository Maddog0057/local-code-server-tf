#locals {
#  gl_user = "<GitLap Username>"
#}

resource "gitlab_user_sshkey" "code_server_gl" {
  title      = "${local.gl_user}@${random_pet.code_server_name.id}.cs"
  key        = tls_private_key.cs_ed25519.public_key_openssh
  expires_at = timeadd(formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timestamp()), "168h")
}

resource "github_user_ssh_key" "code_server_gh" {
  title = "${local.gl_user}@${random_pet.code_server_name.id}.cs"
  key   = tls_private_key.cs_ed25519.public_key_openssh
}

/*
data "onepassword_item" "remote_docker_creds" {
  vault = local.vault_id
  uuid  = local.op_ssh_id
}

resource "null_resource" "copy_key" {
  triggers = {
    invokes_me_everytime = uuid()
    cs_pubKey            = tls_private_key.cs_ed25519.public_key_openssh
    sv_host              = data.onepassword_item.remote_docker_creds.url
    sv_user              = data.onepassword_item.remote_docker_creds.username
    sv_pass              = data.onepassword_item.remote_docker_creds.password
  }
  connection {
    type     = "ssh"
    host     = self.triggers.sv_host
    user     = self.triggers.sv_user
    password = self.triggers.sv_pass
  }
  provisioner "remote-exec" {
    when = create
    inline = [
      "#!/bin/bash",
      "echo \"${trimspace(self.triggers.cs_pubKey)} ${self.triggers.sv_user}@${random_pet.code_server_name.id}.cs\" >> ~/.ssh/authorized_keys"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "#!/bin/bash",
      "sed -i.bak '/${replace(trimspace(self.triggers.cs_pubKey), "/", "\\/")}/d' ~/.ssh/authorized_keys"
    ]
  }
}
*/
